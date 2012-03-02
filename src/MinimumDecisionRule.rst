The source code for this section can be found in the file
``MinimumDecisionRule.cxx``.

The {Evaluate()} method of the {MinimumDecisionRule} returns the index
of the smallest discriminant score among the vector of discriminant
scores that it receives as input.

To begin this example, we include the class header file. We also include
the header file for the {std::vector} class that will be the container
for the discriminant scores.

::

    [language=C++]
    #include "itkMinimumDecisionRule.h"
    #include <vector>

The instantiation of the function is done through the usual {New()}
method and a smart pointer.

::

    [language=C++]
    typedef itk::Statistics::MinimumDecisionRule DecisionRuleType;
    DecisionRuleType::Pointer decisionRule = DecisionRuleType::New();

We create the discriminant score vector and fill it with three values.
The call {Evaluate( discriminantScores )} will return 0 because the
first value is the smallest value.

::

    [language=C++]
    DecisionRuleType::MembershipVectorType discriminantScores;
    discriminantScores.push_back( 0.1 );
    discriminantScores.push_back( 0.3 );
    discriminantScores.push_back( 0.6 );

    std::cout << "MinimumDecisionRule: The index of the chosen = "
    << decisionRule->Evaluate( discriminantScores )
    << std::endl;

