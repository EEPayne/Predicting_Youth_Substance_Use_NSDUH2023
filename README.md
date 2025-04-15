---
title: "DATA5322-SP25 Practical Homework 1"
author: "Elling Payne"
---

### Background

The National Survey on Drug Use and Health (NSDUH) [1] in 2023 collected data from adults and children over 12 in the United States, who were not institutionalized or in the military. The data collected includes self-reported information about participants' drug use, demographic information, social information, and behavioral information. This data was then consolidated and filtered by Professor Mendible of Seattle University [3].

### Problem Statement

Possible Questions:
- Can the non-substance features predict whether a youth has ever used a tobacco product?
- Can the non-substance features predict whether a youth drank never, seldom, or more often in the past year?
- Can the non-substance features predict how many days in the past year a youth used marijuana?

### Project Structure
At the root level live all of the code files, r-notebooks, and documentation. "preprocessing.R" may be sourced to produce the data need by "modeling_forests.Rmd", which handles the bulk of the analysis and modeling tasks. It also produces a seperate training and test set for each of the three problems addressed. Input files obtained from [3] are stored in "in/". Output from preprocessing and analysis steps resides in the "out/" directory.

### References

[1] Center for Behavioral Health Statistics and Quality. (2024). *2023 National Survey on Drug Use and Health (NSDUH)*, Substance Abuse and Mental Health Services 	Administration. Rockville, MD

[2] Center for Behavioral Health Statistics and Quality. (2024). *2023 National Survey on Drug Use and Health Public Use File Codebook* Substance Abuse and Mental Health Services Administration. Rockville, MD

[3] Mendible, Ariana. (2025). *5322* [source code]. GitHub. https://github.com/mendible/5322

[4]  R Core Team (2025). *R: A language and Environment for Statistical Computing*. R Foundation for Statistical Computing, Vienna, 	Austria. https://www.R-project.org

[5] Wickham H, Averick M, Bryan J, Chang W, McGowan LD, François R, Grolemund G, Hayes A, Henry L, Hester J, Kuhn M, Pedersen TL, 	Miller E, Bache SM, Müller K, Ooms J, Robinson D, Seidel DP, Spinu V, Takahashi K, Vaughan D, Wilke C, Woo K, Yutani H 	(2019). “Welcome to the tidyverse.” *Journal of Open Source Software*, 4(43), 1686. doi:10.21105/joss.01686.

[6] Ripley, B.D. (2023). *Tree: Classification and Regression Trees*. R package version 1.0-43.
    https://CRAN.R-project.org/package=tree

[7] Liaw A, Wiener M (2002). “Classification and Regression by randomForest.” *R News*, 2(3), 18-22.
    https://CRAN.R-project.org/doc/Rnews/.

[8] Ridgeway, G., Greenwell, B., Boehmke, B., GBM Developers. (2024). *gbm: Generalized Boosted Regression Models*. R package version 2.2.2. https://CRAN.R-project.org/package=gbm

