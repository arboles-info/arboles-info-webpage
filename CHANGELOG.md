## v0.7.0 (2026-01-14)

### Feat

- Introduce new 'osm' Django app and add extensive static files for admin, GIS, and third-party libraries. (#68)

## v0.6.2 (2025-12-02)

### Fix

- added update lat and long when map is moved (#64)

## v0.6.1 (2025-12-02)

### Fix

- changes map behaviour (#63)

## v0.6.0 (2025-12-02)

### Feat

- **maps/views.py**: changes overpass api for maps.mail.ru (#62)

## v0.5.0 (2025-12-01)

### Feat

- **welcom.html**: changes the welcome page adding cards (#61)

## v0.4.0 (2025-11-25)

### Feat

- **templates/base.html**: added contact to footer component (#59)

## v0.3.2 (2025-11-24)

### Fix

- **Makefile**: Makefile compsose-migrate target (#54)

## v0.3.1 (2025-11-23)

### Fix

- adds health url (#52)

## v0.3.0 (2025-11-23)

### Feat

- added compose and postgis in local environment (#51)

## v0.2.2 (2025-11-23)

### Fix

- **Dockerfile**: fixes error with static folder when collectstatic (#50)

## v0.2.1 (2025-11-23)

### Fix

- added whitenoise to fix statics 404 (#49)

## v0.2.0 (2025-11-23)

### Feat

- adds a middleware for production ALLOWED_HOSTS (#48)

## v0.1.19 (2025-11-23)

### Fix

- **settings.py**: changes SSL behaviour (#47)

## v0.1.18 (2025-11-21)

### Fix

- allowed hosts (#46)

## v0.1.17 (2025-11-21)

### Fix

- **Dockerfile**: removes PORT variable (#45)

## v0.1.16 (2025-11-21)

### Fix

- **app-spec.yaml**: deletes run command (#44)

## v0.1.15 (2025-11-20)

### Fix

- **app-spec.yaml**: fixes deployment command (#42)

## v0.1.14 (2025-11-20)

### Fix

- forces release pipeline

## v0.1.13 (2025-11-20)

### Fix

- **.circleci/config.yml**: circle configuration docker version (#40)

## v0.1.12 (2025-11-20)

### Fix

- **.circleci/config.yml**: circle configuration version filtering (#39)

## v0.1.11 (2025-11-20)

### Fix

- **.circleci/config.yml**: circle configuration (#38)

## v0.1.10 (2025-11-20)

### Fix

- **.config/circleci**: cicd simplified (#37)

## v0.1.9 (2025-11-20)

### Fix

- **.config/circleci**: cicd simplified (#37)

## v0.1.9 (2025-11-20)

## v0.1.8 (2025-11-14)

### Fix

- **pyproject.toml**: changes bump_message template

## v0.1.7 (2025-11-14)

### Fix

- **.circleci/config.yml**: circle configuration

## v0.1.6 (2025-11-14)

### Fix

- **.circleci/config.yml**: config fix

## v0.1.5 (2025-11-14)

### Fix

- **.circleci/config.yml**: removed filters

## v0.1.4 (2025-11-14)

### Fix

- **.circleci/config.yml**: moved filters to workflow

## v0.1.3 (2025-11-14)

### Fix

- **.circleci/config.yml**: removed docker remote version

## v0.1.2 (2025-11-14)

### Fix

- **.circleci/config.yml**: fixed version in workflows error

## v0.1.1 (2025-11-14)

### Fix

- **.circleci/config.yml**: fixed yaml error

## v0.1.0 (2025-11-14)

### Feat

- fixes verison on main workflow

## v0.0.8 (2025-11-14)

### Fix

- **.circleci/config.yml**: add filters to all main jobs

## v0.0.7 (2025-11-14)

### Fix

- **.circleci/config.yml**: fixes filters adding to each job

## v0.0.6 (2025-11-14)

### Fix

- **.circleci/config.yml**: restore correct workflow filters for tags

## v0.0.5 (2025-11-14)

### Fix

- **.circleci/config.yml**: Delete docker version from config

## v0.0.4 (2025-11-14)

### Fix

- **.circleci/config.yml**: changed filter of the main workflow (#36)

## v0.0.3 (2025-11-13)

### Fix

- testing pipeline

## v0.0.2 (2025-11-13)

## v0.0.1 (2025-11-13)

### Feat

- **ci**: add manual workflow execution support
- includes conventional commits and tagging github action (#35)
- web application migrated to django (#32)
- epic frontend change (#26)
- added robots.txt (#16)
- adds a welcome page and moves map to /mapa (#15)
- front cleaning (#13)
- **static/app.js**: added disabling behaviour to Load Data button (#11)
- enables geo location in web browser (#10)
- first vresion of the application running

### Fix

- **README.md**: forces new tag
- **ci**: handle protected branch push errors gracefully
- **ci**: create initial tag v0.0.0 if no tags exist
- **ci**: correct pyproject.toml multiline string format
- fixes digitalocean deployment (#33)
- adds retries to API trees and stump requests (#31)
- static error in path analyzing in main.py (#30)
- refactor to src and timeout fixed (#28)
- **static/styles.css**: fixes mobile map (#27)
- cheats frontend visualization and default behaviour (#14)
- **static/app.js**: auto-load check button now reload data (#12)
- **main.py**: fixes opendata object parsing (#9)
- **main.py**: fixes api stump GET issue (#8)
