# Theo Blauberg


### Profile

Senior Analytics Engineer with an advanced degree in Economics and
extensive experience in econometrics, machine learning, and
experimentation. Currently completing a Master’s in Data Science at the
University of Helsinki. Proficient in R, Python, SQL, and GPU computing.
Experienced in building production ML models, interactive data
applications, and internal analytics tooling.

### Contact

<script src="https://kit.fontawesome.com/954a9d9f43.js" crossorigin="anonymous"></script>
<ul class="fa-ul" style="list-style-type: none;">
<li>
<i class="fa-solid fa-mobile-screen"></i> +358407181510
</li>
<li>
<i class="fa-solid fa-at"></i> theo.blauberg@outlook.com
</li>
<li>
<i class="fa-brands fa-github"></i> [Github](https://github.com/bbtheo)
</li>
<li>
<i class="fa-brands fa-linkedin"></i>
[Linkedin](https://www.linkedin.com/in/theo-blauberg/)
</li>
</ul>

## Education

### Master’s Program in Data Science

**University of Helsinki**  
09/2021 -  

- **Major:** Data Science
- Specializing in machine learning methods with emphasis on
  GPU-accelerated computing.
- [**Thesis:**](https://github.com/bbtheo/ds-thesis) Applying tabular
  foundation models to the detection of fraud patterns in
  high-dimensional transaction data. Work in progress; [current
  draft](https://bbtheo.github.io/ds-thesis/).

### Master’s Program in Economics

**University of Helsinki**  
09/2020 - 12/2022  

- **Major:** Economics
- **Minors:** Statistics, Mathematics, Computer Science
- [**Master’s
  Thesis:**](https://github.com/bbtheo/gradu/blob/main/docs/bookdown-thesis.pdf)
  Impact of Policy Shocks in the EU Emissions Trading System on Finland.

### Exchange Program

**Fudan University, Shanghai**  
09/2018 - 06/2019  
Studied Chinese language, politics, and economics, with focus on East
Asian economic development.

### Language Course

**University of Vienna**  
09/2015 - 12/2015  
Intensive German language studies.

## Technical Skills

**Languages:** R, Python, SQL, Julia, C++  
**Methods:** causal inference, RCT analysis, time-series econometrics  
**ML/AI:** Torch, tidymodels, scikit-learn, Claude Agent SDK, Anthropic
Python SDK, Chatlas  
**Data:** dplyr, DuckDB, pandas, Arrow, Spark, Hive, Impala, Snowflake  
**GPU:** CUDA Python, RAPIDS cuDF  
**Engineering:** Docker, GitHub Actions, pytest, testthat  
**Web:** Shiny, Quarto, PowerBI, REST APIs  

## Certifications

- **NVIDIA:** Fundamentals of Deep Learning
- **NVIDIA:** Fundamentals of Accelerated Computing with CUDA Python

## Work Experience

### Senior Analytics Engineer

**Nordea**

07/2025 -

- Build, maintain, and monitor machine learning models that deliver
  real-time fraud detection for card and account-to-account
  transactions.
- Lead analytics initiatives with increased autonomy in model
  development and deployment decisions.
- Maintain an internal R package for data analysis and visualization,
  significantly improving team productivity.

### Data Analyst

**Nordea**

07/2023 - 07/2025

- Collaborated within a team responsible for building and monitoring
  real-time fraud detection models.
- Developed internal R packages, Shiny apps, and automated reports.
  Established a Data & Analytics community within the department.

### Data Analyst

**VATT Institute for Economic Research**

01/2023 - 06/2023

- Conducted analyses and co-authored research reports on electricity
  market data, focusing on
  [consumer](https://scholar.google.fi/citations?view_op=view_citation&hl=en&user=19yd6u0AAAAJ&sortby=pubdate&citation_for_view=19yd6u0AAAAJ:2tRrZ1ZAMYUC)
  and
  [company](https://scholar.google.fi/citations?view_op=view_citation&hl=en&user=19yd6u0AAAAJ&sortby=pubdate&citation_for_view=19yd6u0AAAAJ:sJsF-0ZLhtgC)
  responses to price shocks.
- Designed and developed a [Shiny-based
  dashboard](https://github.com/datahuone/shiny_app) for interactive
  data visualization.

### Research Assistant

**VATT Institute for Economic Research**

08/2022 - 01/2023

- Supported research projects with data preparation, analysis, and
  visualization tasks.

### Project Worker

**City of Tampere**

05/2022 - 08/2022

- Analysed a randomised controlled experiment (~5,000 users) testing
  whether information nudges could shift mobility behaviour, as part of
  the Keli project (Kestävämmän liikkumisen kehittäminen
  hiilijalanjälkilaskurin avulla).
- Project co-funded by the Ministry of the Environment. Results
  published in a [working
  paper](https://scholar.google.fi/citations?view_op=view_citation&hl=en&user=19yd6u0AAAAJ&sortby=pubdate&citation_for_view=19yd6u0AAAAJ:NyGDZy8z5eUC).

### Intern

**Embassy of Finland in Vienna**

05/2021 - 08/2021

- Monitored and reported on Austrian economic developments to inform
  Finnish Government policy decisions.
- Attended and reported on meetings with UN organizations and local
  politicians.

## Projects

### Running Coach - Self-Hosted Training Planner

- Building a self-hosted running coach that ingests Apple Health data
  into a canonical activity and vitals schema, maintains fitness and
  injury-load ledgers, and generates weekly plans from a deterministic
  guardrail engine.
- A Claude Agent SDK reviewer proposes plan changes that are validated
  against the guardrails before application. Python, FastAPI, SQLite,
  Docker; deployed on a home server behind Tailscale with pytest
  coverage across the engine.

### cuplyr - GPU-Accelerated dplyr

- Developing an R package that enables standard dplyr code to execute on
  GPU hardware through a RAPIDS cuDF backend.
- Implements lazy evaluation with automatic query optimizations.
  Benchmarks show 40-77x speedups over dplyr on GPU-resident data;
  parity end-to-end including transfer.
- [GitHub](https://github.com/bbtheo/cuplyr)

### digitraffic - Fintraffic API Client

- Building an R package for Finland’s Digitraffic road traffic sensor
  time series: 450+ roadside sensors, per-vehicle records, real-time and
  historical.
- Features tidyverse-native output, spatial filtering, built-in caching,
  and rate limiting. Tested with GitHub Actions; to be submitted to
  CRAN.
- [GitHub](https://github.com/bbtheo/digitraffic)

### bracketeer - Tournament Management Framework

- Developed an R package for modeling and executing tournament
  competitions with support for multiple formats including round-robin,
  Swiss system, and elimination brackets.
- Features a pipe-first API design for defining reusable tournament
  blueprints with automatic stage materialization and flexible result
  entry.
- [GitHub](https://github.com/bbtheo/bracketeer)

### Reseptor - Recipe Assistant

- [Python Shiny app](https://github.com/bbtheo/reseptor) for interactive
  recipe creation on the Claude API via Chatlas.

## Positions of Responsibility

### Vote Counter - UNIDO

Authorized by the Western countries group to serve as vote counter in
the Secretary-General Election of the United Nations Industrial
Development Organization.

### Board Member - Economics Students’ Association

Served on the board contributing to strategic planning and student
activities.
