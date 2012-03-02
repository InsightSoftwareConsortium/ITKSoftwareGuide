The source code for this section can be found in the file
``MaximumDecisionRule.cxx``.

The {MaximumDecisionRule} returns the index of the largest discriminant
score among the discriminant scores in the vector of discriminant scores
that is the input argument of the {Evaluate()} method.

To begin the example, we include the header files for the class and the
MaximumDecisionRule. We also include the header file for the
{std::vector} class that will be the container for the discriminant
scores.

::

    [language=C++]
    #include "itkMaximumDecisionRule.h"
    #include <vector>

The instantiation of the function is done through the usual {New()}
method and a smart pointer.

::

    [language=C++]
    typedef itk::Statistics::MaximumDecisionRule DecisionRuleType;
    DecisionRuleType::Pointer decisionRule = DecisionRuleType::New();

We create the discriminant score vector and fill it with three values.
The {Evaluate( discriminantScores )} will return 2 because the third
value is the largest value.

::

    [language=C++]
    DecisionRuleType::MembershipVectorType discriminantScores;
    discriminantScores.push_back( 0.1 );
    discriminantScores.push_back( 0.3 );
    discriminantScores.push_back( 0.6 );

    std::cout << "MaximumDecisionRule: The index of the chosen = "
    << decisionRule->Evaluate( discriminantScores )
    << std::endl;

