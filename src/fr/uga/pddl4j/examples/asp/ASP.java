/*
 * Copyright (c) 2021 by Damien Pellier <Damien.Pellier@imag.fr>.
 *
 * This file is part of PDDL4J library.
 *
 * PDDL4J is free software: you can redistribute it and/or modify * it under the terms of the GNU General Public License
 * as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * PDDL4J is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License * along with PDDL4J.  If not,
 * see <http://www.gnu.org/licenses/>
 */

package fr.uga.pddl4j.examples.asp;

import fr.uga.pddl4j.heuristics.state.StateHeuristic;
import fr.uga.pddl4j.parser.DefaultParsedProblem;
import fr.uga.pddl4j.parser.RequireKey;
import fr.uga.pddl4j.plan.Plan;
import fr.uga.pddl4j.plan.SequentialPlan;
import fr.uga.pddl4j.planners.*;
import fr.uga.pddl4j.problem.DefaultProblem;
import fr.uga.pddl4j.problem.Problem;
import fr.uga.pddl4j.problem.State;
import fr.uga.pddl4j.problem.operator.Action;
import fr.uga.pddl4j.problem.operator.ConditionalEffect;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import picocli.CommandLine;

import java.util.*;

import java.util.Random;

@CommandLine.Command(name = "ASP",
        version = "ASP 1.0",
        description = "Solves a specified planning problem using A* search strategy.",
        sortOptions = false,
        mixinStandardHelpOptions = true,
        headerHeading = "Usage:%n",
        synopsisHeading = "%n",
        descriptionHeading = "%nDescription:%n%n",
        parameterListHeading = "%nParameters:%n",
        optionListHeading = "%nOptions:%n")


public class ASP extends AbstractPlanner {
    private static final Logger LOGGER = LogManager.getLogger(ASP.class.getName());
    public static final String HEURISTIC_SETTING = "HEURISTIC";
    public static final StateHeuristic.Name DEFAULT_HEURISTIC = StateHeuristic.Name.AJUSTED_SUM;
    /**
     * The WEIGHT_HEURISTIC property used for planner configuration.
     */
    public static final String WEIGHT_HEURISTIC_SETTING = "WEIGHT_HEURISTIC";
    /**
     * The default value of the WEIGHT_HEURISTIC property used for planner configuration.
     */
    public static final double DEFAULT_WEIGHT_HEURISTIC = 1.0;
    /**
     * The stochastic pruning property for deciding if a node must be dropped.
     */
    public static boolean stochasticPruning = false;

    /**
     * The total number of states evaluated
     */
    private int numOfStatesEvaluated = 0;
    /**
     * The weight of the heuristic.
     */
    private double heuristicWeight;
    /**
     * The name of the heuristic used by the planner.
     */
    private StateHeuristic.Name heuristic;
    /**
     * Creates a new A* search planner with the default configuration.
     */
    public ASP() {
        this(ASP.getDefaultConfiguration());
    }
    /**
     * Creates a new A* search planner with a specified configuration.
     *
     * @param configuration the configuration of the planner.
     */
    public ASP(final PlannerConfiguration configuration) {
        super();
        this.setConfiguration(configuration);
    }

    /**
     * Sets the weight of the heuristic.
     *
     * @param weight the weight of the heuristic. The weight must be greater than 0.
     * @throws IllegalArgumentException if the weight is strictly less than 0.
     */
    @CommandLine.Option(names = {"-w", "--weight"}, defaultValue = "1.0",
            paramLabel = "<weight>", description = "Set the weight of the heuristic (preset 1.0).")
    public void setHeuristicWeight(final double weight) {
        if (weight <= 0) {
            throw new IllegalArgumentException("Weight <= 0");
        }
        this.heuristicWeight = weight;
    }
    /**
     * Set the stochastic pruning flag.
     *
     * @param value the assigned value to the flag.
     */
    @CommandLine.Option(names = {"-sp", "--stochastic-pruning"}, defaultValue = "false",
            paramLabel = "<value>", description = "Set the stochastic-pruning flag (preset false).")
    public void setStochasticPruning(final String value) {
        this.stochasticPruning = value.equalsIgnoreCase("true") ? true : false;
    }

    /**
     * Set the name of heuristic used by the planner to the solve a planning problem.
     *
     * @param heuristic the name of the heuristic.
     */
    @CommandLine.Option(names = {"-e", "--heuristic"}, defaultValue = "AJUSTED_SUM",
            description = "Set the heuristic : FAST_FARWARD, AJUSTED_SUM, AJUSTED_SUM2, AJUSTED_SUM2M, COMBO, "
                    + "MAX, FAST_FORWARD SET_LEVEL, SUM, SUM_MUTEX (preset: FAST_FORWARD)")
    public void setHeuristic(StateHeuristic.Name heuristic) {
        this.heuristic = heuristic;
    }

    /**
     * Returns the name of the heuristic used by the planner to solve a planning problem.
     *
     * @return the name of the heuristic used by the planner to solve a planning problem.
     */
    public final StateHeuristic.Name getHeuristic() {
        return this.heuristic;
    }

    /**
     * Returns the weight of the heuristic.
     *
     * @return the weight of the heuristic.
     */
    public final double getHeuristicWeight() {
        return this.heuristicWeight;
    }

    /**
     * Instantiates the planning problem from a parsed problem.
     *
     * @param problem the problem to instantiate.
     * @return the instantiated planning problem or null if the problem cannot be instantiated.
     */
    @Override
    public Problem instantiate(DefaultParsedProblem problem) {
        final Problem pb = new DefaultProblem(problem);
        pb.instantiate();
        return pb;
    }

    /**
     * Checks the planner configuration and returns if the configuration is valid.
     * A configuration is valid if (1) the domain and the problem files exist and
     * can be read, (2) the timeout is greater than 0, (3) the weight of the
     * heuristic is greater than 0 and (4) the heuristic is a not null.
     *
     * @return <code>true</code> if the configuration is valid <code>false</code> otherwise.
     */
    public boolean hasValidConfiguration() {
        return super.hasValidConfiguration()
                && this.getHeuristicWeight() > 0.0
                && this.getHeuristic() != null;
    }

    /**
     * This method return the default arguments of the planner.
     *
     * @return the default arguments of the planner.
     * @see PlannerConfiguration
     */
    public static PlannerConfiguration getDefaultConfiguration() {
        PlannerConfiguration config = Planner.getDefaultConfiguration();
        config.setProperty(ASP.HEURISTIC_SETTING, ASP.DEFAULT_HEURISTIC.toString());
        config.setProperty(ASP.WEIGHT_HEURISTIC_SETTING,
                Double.toString(ASP.DEFAULT_WEIGHT_HEURISTIC));
        return config;
    }

    /**
     * Returns the configuration of the planner.
     *
     * @return the configuration of the planner.
     */
    @Override
    public PlannerConfiguration getConfiguration() {
        final PlannerConfiguration config = super.getConfiguration();
        config.setProperty(ASP.HEURISTIC_SETTING, this.getHeuristic().toString());
        config.setProperty(ASP.WEIGHT_HEURISTIC_SETTING, Double.toString(this.getHeuristicWeight()));
        return config;
    }

    /**
     * Sets the configuration of the planner. If a planner setting is not defined in
     * the specified configuration, the setting is initialized with its default value.
     *
     * @param configuration the configuration to set.
     */
    @Override
    public void setConfiguration(final PlannerConfiguration configuration) {
        super.setConfiguration(configuration);
        if (configuration.getProperty(ASP.WEIGHT_HEURISTIC_SETTING) == null) {
            this.setHeuristicWeight(ASP.DEFAULT_WEIGHT_HEURISTIC);
        } else {
            this.setHeuristicWeight(Double.parseDouble(configuration.getProperty(
                    ASP.WEIGHT_HEURISTIC_SETTING)));
        }
        if (configuration.getProperty(ASP.HEURISTIC_SETTING) == null) {
            this.setHeuristic(ASP.DEFAULT_HEURISTIC);
        } else {
            this.setHeuristic(StateHeuristic.Name.valueOf(configuration.getProperty(
                    ASP.HEURISTIC_SETTING)));
        }
    }


    /**
     * Search for a plan using A* algorithm.
     *
     * @param problem the problem for which the plan must be found.
     * @return a plan if it is found within the time limit, otherwise null.
     */

    public Plan astarSearch(Problem problem) {
        StateHeuristic heuristic = StateHeuristic.getInstance(this.getHeuristic(), problem);
        Random random = new Random();
        // Get the initial state from the planning problem
        State init = new State(problem.getInitialState());
        // An HashMap was used instead of a set in order to have a data structure that has constant access time and membership checking
        // With a set the former would be O(N) instead of O(1)
        Map<State, Node> exploredNodes = new HashMap<>();
        Map<State, Node> nodesToExploreSet = new HashMap<>();
        double heuristicWeight = this.getHeuristicWeight();
        // The list stores the node ordered according to the A* (getFValue = g + h) function
        PriorityQueue<Node> nodesToExplore = new PriorityQueue<Node>(problem.getActions().size(), new Comparator<Node>() {
            public int compare(Node n1, Node n2) {
                double f1 = heuristicWeight * n1.getHeuristic() + n1.getCost();
                double f2 = heuristicWeight * n2.getHeuristic() + n2.getCost();
                return Double.compare(f1, f2);
            }
        });
        // Creates the root node of the tree search
        Node root = new Node(init, null, -1, 0, heuristic.estimate(init, problem.getGoal()));
        // Adds the root to the list of nodes to be explored
        nodesToExplore.add(root);
        nodesToExploreSet.put(init, root);

        // even though the termination condition is  for the search space to completely explored,
        // the algorithm terminates much earlier
        while (!nodesToExplore.isEmpty()) {
            // Pop the first node in the pending list open
            Node current = nodesToExplore.poll();
            // updating the number of states visited
            this.numOfStatesEvaluated += 1;
            // removingthe node from the set of explored nodes
            nodesToExploreSet.remove(current);
            exploredNodes.put(current, current);
            // If the goal is reached then extract a plan and return it
            if (current.satisfy(problem.getGoal())) return extractPlan(current, problem);
            // Try to apply the operators of the problem to this node
            int i = 0;

            for (Action op : problem.getActions()) {

                // Test if a specified operator is applicable in the current state (i.e verifying whether the precondition
                // of the action are satisfied)
                if (op.isApplicable(current)) {
                    Node state = new Node(current);
                    // based on the value of the flag stochastic pruning, we must distinguish between two cases; the
                    // first is whether it's value is false; in this case we proceed to generate ALL the children state.
                    // In the remaining case, that is when stocastich pruning is enabled, there is a probability of 50%
                    // of generating the child state of the node current.
                    boolean generateChild = random.nextBoolean();
                    if ((this.stochasticPruning && generateChild) || (!this.stochasticPruning)) {
                        List<ConditionalEffect> effects = op.getConditionalEffects();
                        // Apply the effect to the child node (state)
                        applyEffects(effects, current, state);

                        double g = current.getCost() + op.getCost().getValue();
                        Node result = nodesToExploreSet.get(state);

                        // if the child node is yet to be explored
                        if (result == null) {
                            result = exploredNodes.get(state);
                            // if the child node was already explored precedently
                            if (result != null) {
                                // if the cumulative cost of the node currently generated is lesser than the
                                // node precedently explored, then we update it's fields and reinsert into the
                                // list of nodes to be explored
                                if (g < result.getCost()) {
                                    updateNode(result, current, g, i);
                                    nodesToExplore.add(result);
                                    nodesToExploreSet.put(result, result);
                                    exploredNodes.remove(result);
                                }
                                // otherwise we have a node that was not explored and yet to be inserted in
                                // the list of nodes to explore
                            } else {
                                updateNode(state, current, g, i);
                                state.setHeuristic(heuristic.estimate(state, problem.getGoal()));
                                nodesToExplore.add(state);
                                nodesToExploreSet.put(state, state);
                            }
                            // otherwise, if it was already added to the queue, we must check if it's cumulative cost
                            // is lesser than the one currenty generated. In the positive case that it is, we update the
                            // node in the list of the pending nodes with the lesser cost.
                        } else if (g < result.getCost()) {
                            updateNode(result, current, g, i);
                        }
                    }
                }
                i++;
            }
        }
        // return the search computed or null if no search was found
        return null;
    }

    /**
     * Update the fields of a node.
     *
     * @param n1 the node for which the fields must be updated.
     * @param n2 the parent node.
     * @param g the cumulative cost.
     * @param i the action index.
     * @return nothing.
     */
    private void updateNode(Node n1, Node n2, double g, int i) {
        n1.setCost(g);
        n1.setParent(n2);
        n1.setAction(i);
        n1.setDepth(n1.getDepth() + 1);
    }

    /**
     * Apply the list of conditional effects to a node.
     *
     * @param effects the list of conditional effects.
     * @param current the current state.
     * @param state the next state.
     * @return nothing.
     */
    private void applyEffects(List<ConditionalEffect> effects, Node current, Node state) {
        for (ConditionalEffect ce : effects) {
            if (current.satisfy(ce.getCondition())) {
                state.apply(ce.getEffect());
            }
        }
    }

    /**
     * Extracts a search from a specified node.
     *
     * @param node    the node.
     * @param problem the problem.
     * @return the search extracted from the specified node.
     */
    private Plan extractPlan(final Node node, final Problem problem) {
        Node n = node;
        final Plan plan = new SequentialPlan();
        while (n.getAction() != -1) {
            final Action a = problem.getActions().get(n.getAction());
            plan.add(0, a);
            n = n.getParent();
        }
        return plan;
    }

    /**
     * Search a solution plan to a specified domain and problem using A*.
     *
     * @param problem the problem to solve.
     * @return the plan found or null if no plan was found.
     */
    @Override
    public Plan solve(final Problem problem) {
        LOGGER.info("Starting search..");

        long startTime = System.currentTimeMillis();
        Plan plan = astarSearch(problem);
        long endTime = System.currentTimeMillis();

        // If a plan is found update the statistics of the planner and log search information
        if (plan != null) {
            LOGGER.info("* A* search succeeded\n");
            LOGGER.info("Number of states evaluated : " + this.numOfStatesEvaluated);
            this.getStatistics().setTimeToSearch(endTime - startTime);
        } else {
            LOGGER.info("* A* search failed\n");
        }

        // Return the plan found or null if the search fails.
        return plan;
    }

    /**
     * The main method of the <code>ASP</code> planner.
     *
     * @param args the arguments of the command line.
     */
    public static void main(String[] args) {
        try {
            final ASP planner = new ASP();
            CommandLine cmd = new CommandLine(planner);
            cmd.execute(args);
        } catch (IllegalArgumentException e) {
            LOGGER.fatal(e.getMessage());
        }
    }

    /**
     * Returns if a specified problem is supported by the planner. Just ADL problem can be solved by this planner.
     *
     * @param problem the problem to test.
     * @return <code>true</code> if the problem is supported <code>false</code> otherwise.
     */
    @Override
    public boolean isSupported(Problem problem) {
        return (problem.getRequirements().contains(RequireKey.ACTION_COSTS)
                || problem.getRequirements().contains(RequireKey.CONSTRAINTS)
                || problem.getRequirements().contains(RequireKey.CONTINOUS_EFFECTS)
                || problem.getRequirements().contains(RequireKey.DERIVED_PREDICATES)
                || problem.getRequirements().contains(RequireKey.DURATIVE_ACTIONS)
                || problem.getRequirements().contains(RequireKey.DURATION_INEQUALITIES)
                || problem.getRequirements().contains(RequireKey.FLUENTS)
                || problem.getRequirements().contains(RequireKey.GOAL_UTILITIES)
                || problem.getRequirements().contains(RequireKey.METHOD_CONSTRAINTS)
                || problem.getRequirements().contains(RequireKey.NUMERIC_FLUENTS)
                || problem.getRequirements().contains(RequireKey.OBJECT_FLUENTS)
                || problem.getRequirements().contains(RequireKey.PREFERENCES)
                || problem.getRequirements().contains(RequireKey.TIMED_INITIAL_LITERALS)
                || problem.getRequirements().contains(RequireKey.HIERARCHY))
                ? false : true;
    }
}



