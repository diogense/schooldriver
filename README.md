#Django-sis 
This is an open source school information system built with Django. It relies heavily on the django admin interface for backend usage (registrar, etc). Below you will find a list of apps included in the software with a brief description of each.

Burke Software and Consulting offers support and hosting for $3000/year for a school of < 500 students. 
[Contact us](http://burkesoftware.com/contact-us/) for details.

# Quick Install
You should have at least basic django deployment experience to run django-sis. We test only in Ubuntu 12.04 and mysql.
Other environments might work but are not supported.

On debian/ubuntu run install/install.sh

If not on debian install everything in install/dependencies.txt using pip. Install reportlab from pip (requires gcc) or 
from a package manager. 

**Configuration**

Modify settings_local.py to add your own settings, such as your database.

**Set up database**

    ./manage.py syncdb --migrate

**Run a test server**

    ./manage.py runserver

You can deploy to production as you would any Django application. https://docs.djangoproject.com/en/dev/howto/deployment/
We do make use of celery for tasks. For a true production environment this should be set up.

## Upgrades

Use south to upgrade the database. Install install/dependencies.txt in case any have updated. Collect static if on a 
production environment. Restart your task scheduler. It should look something like

    ./manage.py migrate
    ./manage.py collectstatic
    pip install --upgrade -r dependencies.txt

We don't currently release stable versions of django-sis. You can assume everything in git is as "stable" as possible. If you 
require more stability consider paying for support.

# Apps

##School Information System (SIS)
This tracks the students’ information and their parent/guardian/contact information. This module also records cohorts (groupings of students for easier class enrollment), basic faculty information, and school year information. This is the central module for django-sis and is required for use of any other module. All other modules are optional.

##Admissions
This tracks potential students and their registration processes. It allows various admission levels to be added as well as steps that need to be completed before moving onto the next level. It also tracks any open houses a student has attended and how the student heard about the school.

![Alt text](https://raw.github.com/burke-software/django-sis/master/screenshots/admissions1.jpg)

Every step in the process can be fully customized to serve your school’s needs. From an applicant's page, the filter function may sort results accordingly.  

![Alt text](https://raw.github.com/burke-software/django-sis/master/screenshots/admissions2.jpg)


##Alumni 
This tracks in which college a student has enrolled after graduating and any alumni actions (such as reunions). Information can be imported from National Student Clearinghouse (http://www.studentclearinghouse.org/). Additionally, SWoRD can store interactions between the former students and current staff as shown below:

![Alt text](https://raw.github.com/burke-software/django-sis/master/screenshots/alumni.jpg)

##Attendance 
The attendance module allows homeroom teachers to take attendance each day and write notes for absentees. SWoRD stores this data and allows users to generate reports, look up single students, aggregate reports, and produce perfect attendance certificates.

![Alt text](https://raw.github.com/burke-software/django-sis/master/screenshots/atndcap.jpg)

##Discipline
The discipline module tracks a student’s discipline information including infractions, actions to be taken, and the teacher who reported the infraction. Similar to the other modules in SWoRD, discipline reports can be generated and exported into an Excel document for convenience. 

![Alt text](https://raw.github.com/burke-software/django-sis/master/screenshots/discipline1.jpg)

##Schedule, Courses, and Grades
These modules track courses, enrollments, marking periods, class periods, marking period grades, student awards, standardized tests information, and results (ex: SAT, ACT, PLAN, etc). SWoRD stores marking period grades and final grades; these grades can then be generated into a report card or transcript. At present, SWoRD supports integration with the free online gradebook Engrade.
![Alt text](https://raw.github.com/burke-software/django-sis/master/screenshots/grades.jpg)

##Volunteer Tracking
This module tracks any volunteer work a student is required to do including site and site supervisor information. A student can volunteer at multiple sites.

Counseling

This tracks students’ counseling meetings and referrals. It allows teachers to submit online referral forms that notify the counselor and also tracks follow-up actions after a meeting.

##Work Study 
The Work Study module involves many different facets. Students from the School Information module can be converted to Student Workers so that more specialized information can be tracked in the Work Study module. Students may submit time sheets for supervisors to approve, make notes, and evaluate the student. This process is shown below:
![Alt text](https://raw.github.com/burke-software/django-sis/master/screenshots/cwsp1.jpg)

All submitted time sheets are stored on SWoRD to allow work study staff to keep track of approved or unapproved time sheets. Users with access to these stored time sheets are able to view each time sheet’s information including date, hours, student accomplishments, and supervisor comments.
![Alt text](https://raw.github.com/burke-software/django-sis/master/screenshots/cwsp2.jpg)

Student work attendance is also tracked, allowing faculty to list reasons for missed work days, fees and to specify when the student will make up for the missed day. 
![Alt text](https://raw.github.com/burke-software/django-sis/master/screenshots/cwsp3.jpg)

SWoRD allows users to save basic company information for each work site associated with the school including Department of Labor forms. Additionally, information from client visits is saved along with the pertinent evaluations shown below. 
![Alt text](https://raw.github.com/burke-software/django-sis/master/screenshots/cwsp4.jpg)

