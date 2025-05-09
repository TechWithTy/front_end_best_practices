Experiments & A/B testing best practices

Last updated: Nov 15, 2024
|
Edit this page

1. Establish a clear hypothesis

A good hypothesis focuses your testing and guides your decision-making. It should include your goal metric, how you think your change will improve it, and any other important context. For example:

    Showing a short tutorial video during onboarding will help users understand how to use our product. As a result, we expect to see more successful interactions with the app, fewer customer support queries, and reduced churn (our primary goal) among tested users.

This is a good hypothesis because it enables you to break down which metrics you'll focus on in your test:

    How many users watch the video
    What portion of the video they viewed
    Successful interactions with the app features
    The number of customer support queries
    Churn rate

Then, once you've collected data with your test, you can use these metrics to analyze if your test was a success or not. 2. Only include affected users

Including users who aren't affected by the experiment can lead to unreliable results. For example, if you're testing a new onboarding flow, you don't want to include users who have already completed the flow.

To avoid including unaffected users, make sure to first filter out ineligible users in your code before checking your feature flag code. For example:
JavaScript

// ✅ Correct. Will exclude unaffected users
function showNewChanges(user) {

if (user.hasCompletedAction) {
return false
}

// other checks

if (posthog.getFeatureFlag('experiment-key') === 'control') {
return false;
}

return true
}

// ❌ Incorrect. Will include unaffected users
function showNewChanges(user) {
if (posthog.getFeatureFlag('experiment-key') === 'control') {
return false;
}

if (user.hasCompletedAction) {
return false
}

// other checks

return true
}

3. Experiment with as small of a change as reasonably possible

Ideally, an experiment should change one thing at a time. This ensures that any change in user behavior can be attributed to what was changed. If there are multiple changes, it's difficult to determine which one caused the change in behavior.

The caveat here is that too small of change can slow your team down. Since running experiments takes time, if you're constantly testing small changes, it will take longer to ship large, meaningful changes.

A good rule of thumb to know if your change is too small is if it's unlikely to impact user behavior significantly. You can use qualitative data from user research, quantitative data from existing logging, or previous experiments to inform this decision. 4. Test your experiment

Sometimes we're so eager to get results from our experiments, we jump straight to running them with all our users. This is okay if everything is set up correctly, but if you've made a mistake, you may be unable to rerun your experiment. To understand why, let's look at an example:

Imagine you're running an experiment with a 50/50 split between control and test. You roll out the experiment to all your users, but a day after launch, you notice that your change is causing the app to crash for all test users. You immediately stop the experiment and fix the root cause of the crash. However, restarting the experiment now will produce unreliable results since many users have already seen your change.

To avoid this problem, you should first test your experiment with a small rollout (e.g., 5% of users) for a few days. Once you're confident everything works correctly, you can start the experiment with the remaining users.

To do this in PostHog, you can edit the rollout percentage of the experiment feature flag:

Here's a list of what to check during your test rollout:

    Logging is working correctly
    No increase in crashes or other errors
    Use session replays to ensure your app is behaving as expected
    Users are assigned to the control and test groups in the ratio you are expecting (e.g., 50/50).

5. Predetermine your test duration

Starting an experiment without deciding how long it should last can cause you to fall victim to the peeking problem. This is when you check the intermediate results for statistical significance, make decisions based on them, and end your experiment too early. Without determining how long your experiment should run, you cannot differentiate between intermediate and final results.

Alternatively, if you don't have enough statistical power (i.e., not enough users to obtain a significant result), you'll potentially waste weeks waiting for results. This is especially common in group-targeted experiments.

For these reasons, PostHog includes a recommended running time calculator in the experiment setup flow. This calculates the minimum sample size required to run your experiment and the duration you should run your experiment for. 6. Use a launch checklist

Launching an A/B test requires careful planning to ensure accurate results and meaningful insights. To help you navigate this, we've put together this launch checklist:

**Before launch**

- [ ] A clear goal metric.
- [ ] A clear hypothesis.
- [ ] Secondary metrics.
- [ ] Counter metrics.
- [ ] Predefined test duration, based on sample size.
- [ ] Code only includes eligible users that will be affected by change.
- [ ] QA checks on both control and test variants.

**24-48 hours after launch:**

- [ ] Volume of users assigned to each variant is as expected.
- [ ] All logging is working correctly and in correct ratios.
- [ ] No increase in crashes or errors.

**At the end of the test duration**

- [ ] Validate or invalidate your hypothesis based on experiment data.
- [ ] Document your results and share with your team for feedback.
- [ ] Ship winning variant code. Delete code for losing variant.

Questions? Ask M
