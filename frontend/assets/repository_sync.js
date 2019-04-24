function RepositoryCheck($repository_check_form) {
  this.$repository_check_form = $repository_check_form;
  this.setup_form();
}

RepositoryCheck.prototype.setup_form = function() {
  var self = this;
  $(document).trigger("loadedrecordsubforms.aspace", this.$repository_check_form);
};

$(document).ready(function() {
  var repositoryCheck = new RepositoryCheck($("#repository_check_form"));
});
