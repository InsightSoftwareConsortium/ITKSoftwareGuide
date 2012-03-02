The source code for this section can be found in the file
``MaximumRatioDecisionRule.cxx``.

MaximumRatioDecisionRule returns the class label using a Bayesian style
decision rule. The discriminant scores are evaluated in the context of
class priors. If the discriminant scores are actual conditional
probabilites (likelihoods) and the class priors are actual a priori
class probabilities, then this decision rule operates as Bayes rule,
returning the class :math:`i` if :math:`p(x|i) p(i) > p(x|j) p(j)
` for all class :math:`j`. The discriminant scores and priors are
not required to be true probabilities.

This class is named the MaximumRatioDecisionRule as it can be
implemented as returning the class :math:`i` if
:math:`\frac{p(x|i)}{p(x|j)} > \frac{p(j)}{p(i)}
` for all class :math:`j`.

We include the header files for the class as well as the header file for
the {std::vector} class that will be the container for the discriminant
scores.

::

    [language=C++]
    #include "itkMaximumRatioDecisionRule.h"
    #include <vector>

The instantiation of the function is done through the usual {New()}
method and a smart pointer.

::

    [language=C++]
    typedef itk::Statistics::MaximumRatioDecisionRule DecisionRuleType;
    DecisionRuleType::Pointer decisionRule = DecisionRuleType::New();

We create the discriminant score vector and fill it with three values.
We also create a vector ({aPrioris}) for the *a priori* values. The
{Evaluate( discriminantScores )} will return 1.

::

    [language=C++]
    DecisionRuleType::MembershipVectorType discriminantScores;
    discriminantScores.push_back( 0.1 );
    discriminantScores.push_back( 0.3 );
    discriminantScores.push_back( 0.6 );

    DecisionRuleType::PriorProbabilityVectorType aPrioris;
    aPrioris.push_back( 0.1 );
    aPrioris.push_back( 0.8 );
    aPrioris.push_back( 0.1 );

    decisionRule->SetPriorProbabilities( aPrioris );
    std::cout << "MaximumRatioDecisionRule: The index of the chosen = "
    << decisionRule->Evaluate( discriminantScores )
    << std::endl;

