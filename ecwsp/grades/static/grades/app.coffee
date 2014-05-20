app = angular.module 'angular_sis', ['restangular', 'uiHandsontable', 'ngRoute']


app.controller 'StudentGradesController', ['$scope', 'GradebookService', '$routeParams', '$route', ($scope, GradebookService, $routeParams, $route) ->
    $scope.columns = [
        { width: 160, value: 'row.course', title: 'Course', fixed: true, readOnly: true}
    ]

    grades_api = GradebookService
    $scope.rows = grades_api.rows
    $scope.changeGrade = grades_api.setGrade
    
    $scope.$on '$routeChangeSuccess', ->
    
        grades_api.student_id = $routeParams.student_id
        grades_api.getGrades({student: grades_api.student_id}).then (grades) ->
            $scope.grades = grades
            # Course | Grade1 | Grade etc | Final
            for grade in grades
                new_row = true
                for row in grades_api.rows
                    if row.course_id == grade.course_id
                        new_row = false
                if new_row
                    final = {grade: 0}
                    grades_api.rows.push({course: grade.course, course_id: grade.course_id, final: final})
            grades_api.addMarkingPeriods(grades, grades_api.rows, $scope.columns, 'course_id')
            
    $scope.comment_button_text = "Show Comments"
    $scope.showComments = () ->
       $scope.comment_button_text = grades_api.toggleComments($scope.columns)
]


app.controller 'CourseGradesController', ['$scope', '$routeParams', '$route', 'GradebookService', ($scope, $routeParams, $route, GradebookService) ->
    $scope.columns = [
        {width: 160, value: 'row.student', title: 'Student', fixed: true, readOnly: true}
    ]

    grades_api = GradebookService
    $scope.rows = grades_api.rows
    $scope.changeGrade = grades_api.setGrade

    $scope.$on '$routeChangeSuccess', ->
        course_id = $routeParams.course_id
        grades_api.course_id = course_id
        
        grades_api.getGrades({course: course_id}).then (grades)->
            grades = grades
            # Student | Grade1 | Grade etc | Final
            for grade in grades
                new_student = true
                this_student = null
                for student in grades_api.rows
                    if student.student_id == grade.student_id
                        new_student = false
                if new_student
                    final = {grade: 0}
                    grades_api.rows.push({student: grade.student, student_id: grade.student_id, final: final})
            grades_api.addMarkingPeriods(grades, grades_api.rows , $scope.columns, 'student_id')

    $scope.comment_button_text = "Show Comments"
    $scope.showComments = () ->
       $scope.comment_button_text = grades_api.toggleComments($scope.columns)
]


app.factory 'GradebookService', ['Restangular', (Restangular) ->
    grades_api = Restangular.all('grades')
    grades_api.marking_periods = []
    grades_api.rows = []
    grades_api.recalculateGrades = (student) ->
        final = 0.0
        num_of_mp = 0
        for marking_period in grades_api.marking_periods
            grade = student['grade' + marking_period.marking_period_id].grade
            gradeFloat = parseFloat(grade)
            if grade != null
                if isNaN(gradeFloat)
                    gradeLower = grade.toLowerCase()
                    if gradeLower == "i"
                        return "I"
                    else if gradeLower in ["p", "lp", "hp"]
                        final += 100
                        num_of_mp += 1
                    else if gradeLower in ["f", "m"]
                        num_of_mp += 1
                else
                    final += gradeFloat
                    num_of_mp += 1
        final_grade = (final / num_of_mp).toFixed(2)
        if isNaN(final_grade)
            student.final.grade = ''
        else
            student.final.grade = final_grade
    
    grades_api.findMarkingPeriods = (grades) ->
        for grade in grades
            new_marking_period = true
            for marking_period in grades_api.marking_periods
                if marking_period.marking_period_id == grade.marking_period_id
                    new_marking_period = false
            if new_marking_period and grade.marking_period != null
                grades_api.marking_periods.push({marking_period: grade.marking_period, marking_period_id: grade.marking_period_id})
    
    grades_api.addMarkingPeriods = (grades, rows, columns, field) ->
        grade_columns = []
        for marking_period in grades_api.marking_periods
            marking_period.grade_key = 'grade' + marking_period.marking_period_id
            new_column = {width: 70, value: 'row.' + marking_period.grade_key + '.grade', title: marking_period.marking_period}
            if edit == 'False'
                new_column.readOnly = true
            columns.push(new_column)
            for row in rows
                for grade in grades
                    if grade[field] == row[field]
                        if grade.marking_period_id == marking_period.marking_period_id
                            row[marking_period.grade_key] = grade
                        else if grade.override_final == true
                            row.final = grade
        new_column = {width: 70, value: 'row.final.grade', title: 'Final'}
        if edit_final == 'False'
            new_column.readOnly = true
        columns.push(new_column)
        for row in rows
            if not row.final.id
                grades_api.recalculateGrades(row)
        grades_api.rows = rows
            
    grades_api.setGrade = (changes, source) ->
        if source != 'loadData'
            for change in changes
                id = change[0]
                row = grades_api.rows[id]
                attribute = change[1]
                if attribute == "final.grade"
                    if row.final.grade in ["", null, "None"]
                        if row.final.id
                            # This exists on the server. Kill it.
                            row.final.remove()
                            row['final'] = {grade: 0}
                        grades_api.recalculateGrades(row)
                    else
                        if row.final.id
                            # Exists - update it
                            row.final.save()
                        else
                            new_grade = {
                                grade: row.final.grade
                                override_final: true
                            }
                            if grades_api.student_id
                                new_grade.student_id = grades_api.student_id
                            else
                                new_grade.student_id = row.student_id
                            if grades_api.course_id
                                new_grade.course_id = grades_api.course_id
                            else
                                new_grade.course_id = row.course_id
                            grades_api.post(new_grade)
                else
                    if not row.final.id
                        grades_api.recalculateGrades(row)
                    instance = row[attribute.split('.')[0]]
                    instance.save()
                
    grades_api.getGrades = (filters) ->
        grades_api.getList(filters).then (grades) ->
            grades_api.findMarkingPeriods(grades)
            grades_api.grades = grades
            return grades
    
    comment_ids = []
    grades_api.toggleComments = (columns) ->
        if comment_ids.length == 0
            for marking_period in grades_api.marking_periods
                for column, key in columns
                    if column.value == 'row.' + marking_period.grade_key + '.grade'
                        columns.splice(key+1, 0, ({width: 160, value: 'row.' + marking_period.grade_key + '.comment', title: marking_period.marking_period + ' Comments'}))
                        comment_ids.push(key+1)
                        break
            return "Hide Comments"
        else
            deleted = 0
            for comment_id in comment_ids
                columns.splice(comment_id - deleted, 1)
                deleted += 1
            comment_ids = []
            return "Show Comments"
            
    return grades_api
]
