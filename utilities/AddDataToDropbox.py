#!/usr/bin/env python
#
# http://code.activestate.com/recipes/578030-dropbox-file-upload-via-web-interface-using-python/
#
# url for public folder: http://dl.dropbox.com/u/61255957/
#
#

""" Scripts to add data to dropbox

./AddDataToDropbox file.txt                     # upload 1 file to Public/MD5 folder (by default)
./AddDataToDropbox dir:/Folder file.txt         # upload 1 file to provided folder
./AddDataToDropbox dir:/Folder *.txt            # upload glob expressions to provided folder
"""

import mechanize
import os
import glob
import hashlib
import shutil

verbose = True

def md5sum_file(file_path):
    md5 = hashlib.md5()
    with open(file_path, 'rb') as f:
        for chunk in iter(lambda: f.read(8192), ''):
            md5.update(chunk)
    return md5.hexdigest()

def upload_files(local_files, remote_dir, email, password):
    """ Upload a local file to Dropbox """

    # Fire up a browser using mechanize
    br = mechanize.Browser()

    br.set_handle_equiv(True)
#    br.set_handle_gzip(True)
    br.set_handle_redirect(True)
    br.set_handle_referer(True)
#    br.set_handle_robots(False)

#    br.set_debug_http(True)
#    br.set_debug_responses(True)
#    br.set_debug_redirects(True)

    br.addheaders = [('User-agent', ' Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1018.0 Safari/535.19')]

    if verbose: print( 'Opening login page...' )
    # Browse to the login page
    r = br.open('https://www.dropbox.com/login')
    # just in case you need the html
    # html = r.read()
    # this shows a lot of info

    print( r.info() )

    if verbose: print( br.title(), br.geturl() )

    # Enter the username and password into the login form
    isLoginForm = lambda l: l.action == "https://www.dropbox.com/login" and l.method == "POST"

    try:
        if verbose: print( 'selecting form...' )
        br.select_form(predicate=isLoginForm)
    except:
        print( 'Unable to find login form.' )
        exit(1);

    br['login_email'] = email
    br['login_password'] = password

    # Send the form
    if verbose: print( 'submitting login form...' )
    response = br.submit()

    # Add our file upload to the upload form once logged in
    isUploadForm = lambda u: u.action == "https://dl-web.dropbox.com/upload" and u.method == "POST"

    for local_file in local_files:
        try:
            br.select_form(predicate=isUploadForm)
        except:
            print( 'Unable to find upload form.' );
            print( 'Make sure that your login information is correct.' );
            exit(1);

        br.form.find_control("dest").readonly = False
        br.form.set_value(remote_dir, "dest")

        remote_file = os.path.basename(local_file)

        if (os.path.isfile(local_file)):
            br.form.add_file(open(local_file, "rb"), "", remote_file)
            # Submit the form with the file
            if verbose: print 'Uploading %s... to <<Dropbox>>:/%s/%s' % (local_file, remote_dir, remote_file),
            br.submit()

            if verbose: print 'Ok'

    print( 'All completed Ok!')

if __name__ == "__main__":
    import sys
    from getpass import getpass

    #email = raw_input("Enter Dropbox email address:")
    email = 'itkexamples@gmail.com'

    password = getpass("Enter Dropbox password:")
    # password = ''

    remote_dir = '/Public/MD5'

    local_files = []

    # allow multiple local file names as input args
    # first arg with 'dir:' prefix is parsed as remote path
    if len(sys.argv) > 1:
        if sys.argv[1].lower().startswith('dir:'):
            remote_dir = sys.argv[1][4:]

            if not remote_dir.startswith('/'):
                remote_dir = '/' + remote_dir

            if verbose: print 'Using remote_dir=', remote_dir
            del sys.argv[1]
        local_files = sys.argv[1:]

    prepared_local_files = []

    for local_file in local_files:
        # explode globs
        if '*' in local_file:
            prepared_local_files += glob.glob(local_file)
        else:
            prepared_local_files.append(local_file)

    if not len(prepared_local_files):
        print 'No local files provided! Quitting.'
        sys.exit(2)

    prepared_local_hashes = []

    for local_file in prepared_local_files:

        local_hash = md5sum_file( local_file )

        local_file_md5 = open( local_file + '.md5', 'wb+' )
        local_file_md5.write( local_hash )
        local_file_md5.close()

        shutil.copyfile( local_file, local_hash )

        prepared_local_hashes.append( local_hash )

    upload_files(prepared_local_hashes, remote_dir, email, password)

    for local_hash in prepared_local_hashes:
        os.remove( local_hash )

    temp = local_files[0]

    print( '****\n' )

    print( '$ git checkout -b Add_' + temp )

    for local_file in prepared_local_files:
        print( '$ git add ' + local_file + '.md5')
        os.remove( local_file )

    print( '$ git commit -a -m \"Add data\"' )
    print( '$ git checkout master' )
    print( '$ git pull origin master' )
    print( '$ git merge --no-ff Add_' + temp )
    print( '$ git push origin master' )
