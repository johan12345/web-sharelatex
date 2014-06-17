define [
	"base"
	"../libs/algolia"
], (App, algolia)->
	App.factory "Institutions", ->
		new AlgoliaSearch("SK53GL4JLY", "1606ccef5b70ac44680b61e6b0285126").initIndex("institutions")

	App.directive "focusInput", ($timeout) ->
		return (scope, element, attr) ->
			scope.$watch attr.focusInput, (value) ->
				if value
					$timeout ->
						element.select()

	App.controller "UpdateForm", ($scope, $http, Institutions)->
		$scope.institutions = []
		$scope.formVisable = false
		$scope.hidePersonalInfoSection = true
		$scope.roles = ["Student", "Post-graduate student", "Post-doctoral researcher", "Lecturer", "Professor"]

		$http.get("/user/personal_info").success (data)->
			$scope.userInfoForm =
				first_name: data.first_name
				last_name: data.last_name
				role: 	   data.role
				institution: data.institution
				_csrf : window.csrfToken

			if getPercentComplete() != 100
				$scope.percentComplete = getPercentComplete()
				$scope.hidePersonalInfoSection = false

		$scope.showForm = ->
			$scope.formVisable = true

		$scope.sendUpdate = ->
			request = $http.post "/user/personal_info", $scope.userInfoForm
			request.success (data, status)->
			request.error (data, status)->
				console.log "the request failed"
			$scope.percentComplete = getPercentComplete()

		getPercentComplete = ->
			results = _.filter $scope.userInfoForm, (value)-> value? and value?.length != 0
			results.length * 20

		$scope.updateInstitutionsList = (inputVal)->

			# this is a little hack to use until we change auto compelete lib with redesign and can 
			# listen for blur events on institution field to send the post
			if inputVal?.indexOf("(") != -1 and inputVal?.indexOf(")") != -1 
				$scope.sendUpdate()
				
			Institutions.search $scope.userInfoForm.institution, (err, response)->
				$scope.institutions = _.map response.hits, (institution)->
					"#{institution.name} (<span class='muted'>#{institution.domain}</span>)"
