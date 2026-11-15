# Full Stack Application Development Capstone Project

## Best Cars Dealership Review Portal

Best Cars is a national car dealership with branches across the United States. This portal lets customers look up any branch, read what other customers said about it, and post a review of their own. Each review is tagged as positive, neutral or negative by a sentiment analyzer.

This is the capstone project for the IBM Full Stack Software Developer Professional Certificate.

## What the application does

- Anyone can browse all dealerships, filter them by state, and open a dealer page to read its reviews.
- Visitors can register, log in and log out.
- Logged-in users can post a review for a dealer, choosing the car make, model and year they bought.
- An admin (Django admin site) manages car makes and car models.
- Static About Us and Contact Us pages describe the company.

## Architecture

| Part | Technology | Location | Port |
| --- | --- | --- | --- |
| Web app, user management, proxy API | Django | `server/djangoapp`, `server/djangoproj` | 8000 |
| Front end | React, plus static HTML pages | `server/frontend` | served by Django |
| Dealers and reviews API | Node.js, Express, MongoDB | `server/database` | 3030 |
| Sentiment analyzer | Flask, NLTK | `server/djangoapp/microservices` | 5050 |
| Car makes and models | Django models on SQLite | `server/djangoapp/models.py` | |

The React pages call the Django endpoints under `/djangoapp/`. Django fetches dealers and reviews from the Express service and asks the sentiment analyzer to score each review.

## Run it locally

You need Python 3.11 or newer, Node.js 18 or newer, and Docker.

1. Start MongoDB and the dealers and reviews API:

   ```bash
   cd server/database
   docker build . -t nodeapp
   docker compose up -d
   ```

2. Start the sentiment analyzer:

   ```bash
   cd server/djangoapp/microservices
   docker build . -t senti_analyzer
   docker run -d -p 5050:5000 senti_analyzer
   ```

3. Build the React front end:

   ```bash
   cd server/frontend
   npm install
   npm run build
   ```

4. Start Django:

   ```bash
   cd server
   python -m venv .venv && source .venv/bin/activate
   pip install -r requirements.txt
   python manage.py makemigrations
   python manage.py migrate
   python manage.py createsuperuser
   python manage.py runserver
   ```

5. Open http://localhost:8000.

The service URLs Django uses are set in `server/djangoapp/.env`.

## API endpoints

Django (`http://localhost:8000`):

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/djangoapp/register` | Create a user |
| POST | `/djangoapp/login` | Log in |
| GET | `/djangoapp/logout` | Log out |
| GET | `/djangoapp/get_cars` | All car makes and models |
| GET | `/djangoapp/get_dealers` | All dealers |
| GET | `/djangoapp/get_dealers/<state>` | Dealers in one state |
| GET | `/djangoapp/dealer/<id>` | One dealer |
| GET | `/djangoapp/reviews/dealer/<id>` | A dealer's reviews with sentiment |
| POST | `/djangoapp/add_review` | Post a review (login required) |

Express (`http://localhost:3030`): `/fetchReviews`, `/fetchReviews/dealer/:id`, `/fetchDealers`, `/fetchDealers/:state`, `/fetchDealer/:id`, `/insert_review`.

Sentiment analyzer (`http://localhost:5050`): `/analyze/<text>`.

## CI/CD and deployment

- `.github/workflows/main.yml` lints the Python code with flake8 and the Express service with JSHint on every push and pull request to `main`.
- `server/Dockerfile`, `server/entrypoint.sh` and `server/deployment.yaml` package the Django app for Kubernetes.

## Submission evidence

The `submission` folder holds the terminal output, cURL output and screenshots collected from a local run of the app for the capstone grading checklist.
