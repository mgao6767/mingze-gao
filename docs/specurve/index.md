# Specification Curve Analysis

## Motivation

More often than not, empirical researchers need to argue that their chosen model specification reigns. If not, they need to run a battery of tests on alternative specifications and report them. The problem is, researchers can fit a few tables each with a few models in the paper at best, and it's extremely hard for readers to know whether the reported results are being cherry-picked.

So, ***why not run all possible model specifications and find a concise way to report them all?***

## The Specification Curve

The idea of specification curve is a direct answer to the question provided by Simonsohn, Simmons and Nelson (2020).[^1] [^2]

To intuitively explain this concept, below is the Figure 2 from my recent paper [Organization Capital and Executive Performance Incentives](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3734710) on the *Journal of Banking & Finance*,[^3] which is used to show the robustness of an substitution effect of organization capital on executive pay-for-performance sensitivity. Therefore, the estimated coefficients for the variable of interest *OC* are expected to be negative across different model specifications.

![specurve-of-oc](/images/specification-curve-of-oc.jpg)

The plot is made up of two parts. The upper panel plots the coefficient estimates of *OC* in various model specifications, in descending order, and the associated 95% confidence intervals. Sample sizes of each model are plotted as bars at the bottom of the upper panel. For simplicity, we annotate only the maximum and minimum coefficient estimates, as well as the threshold of zero. The lower panel reports the exact specification for each model, where colored dots indicate the choices from various specification alternatives. Both panels share the same x-axis of model number.

To interpret this specification curve, for example, *OC* has an estimated coefficient of −0.11 in the first model, which uses the natural logarithm of *DELTA_MGMT* (a measure of executive pay-for-performance sensitivity) as the dependent variable, and control variables as in the baseline model, including industry fixed effects and year fixed effects, clustering standard errors at the firm level, and is estimated on the full sample.

Further, the ordered nature of the curve implies that this is the minimum estimated impact of OC on ln(*DELTA_MGMT*), whereas the maximum estimated coefficient is doubled at −0.22 when the industry fixed effects are replaced with the more conservative firm fixed effects and estimated on the sample excluding global financial crisis period. More importantly, in all specifications, we find the coefficient estimates of OC to be statistically significant. Using an alternative measure of executive pay-for-performance sensitivity as the dependent variable, again, has minimal impact on the documented substitution effect of *OC*.

This specification curve reports a total of $2\times2\times4\times1\times2=32$ specifications:

- 2 choices of dependent variables (as alternative measures of executive pay-for-performance sensitivity)
- 2 choices of controls variables (controlling for managerial ability at the cost of reduced sample size)
- 4 choices of fixed effects 
- 1 choice of standard error clustering
- 2 choices of sample periods 

Beyond reporting all estimates from hundreds and thousands of models, the more appealing point of specification curve is that we can identify the most impactful factors in specifying the model. As the models are sorted by the coefficient estimates, the distribution of dots in the lower panel can reveal whether certain specification choices drive the results. 

- Alternative measures of executive pay-for-performance sensitivity do not affect the main findings.
- The inclusion of additional control variable of managerial ability does not affect the main findings.
- The industry and year fixed effects seem to lead to weaker coefficient estimates for the variable of interest, albeit the more conservative firm and year fixed effects lead to stronger ones. This is very important.
- The main findings hold with and without the global financial crisis (GFC) period.

Of course, even 32 models cannot exhaust *all* possible specifications. Nevertheless, by addressing the most critical ones, we are able to use *one* specification curve plot to convince readers that our findings are robust.

## `specurve` - Stata command for specification curve analysis

Since there was no available software or package to conduct specification curve analysis. I wrote myself a Stata command **`specurve`**, open-sourced at [github.com/mgao6767/specurve](https://github.com/mgao6767/specurve).

### Dependencies

[`specurve`](https://github.com/mgao6767/specurve) depends on Stata 16's Python integration and requires a Python version of 3.6 or above.

Python modules required:

* [`pandas`](https://pandas.pydata.org/): for basic dataset manipulation.
* [`pyyaml`](https://pyyaml.org/): for reading and parsing the YAML-formatted configuration file.
* [`plotly`](https://plotly.com/python/): for generating the specification curve plot.
* [`kaleido`](https://github.com/plotly/Kaleido): for static image export with `plotly`.

To install the required modules, try:

```
pip install pandas pyyaml plotly kaleido
```

### Installation

Download `specurve.ado` and `specurve.hlp` and put them in your personal ado folder. To find the path to your personal ado folder, type `adopath` in Stata.

### Example usage

The associated help file contains a step-by-step guide on using `specurve`. To open the help file, type `help specurve` in Stata after installation.

### Example output

![example1](https://github.com/mgao6767/specurve/raw/main/images/example1.png)

![example2](https://github.com/mgao6767/specurve/raw/main/images/example2.png)



[^1]: Simonsohn, Uri and Simmons, Joseph P. and Nelson, Leif D., 2020, Specification Curve Analysis, *Nature Human Behaviour*.

[^2]: Special thanks to [Rawley Heimer](https://www.bc.edu/bc-web/schools/carroll-school/faculty-research/faculty-directory/rawley-heimer.html) from Boston College who visited our discipline in 2019 and introduced the Specification Curve Analysis to us in the seminar on research methods. 

[^3]: Gao, M. Leung, H. and Qiu, B. (2021). Organization Capital and Executive Performance Incentives, *Journal of Banking & Finance*, 123, 106017.