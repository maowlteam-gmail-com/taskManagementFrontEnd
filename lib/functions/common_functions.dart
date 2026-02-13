String roleToDisplay(String role) {
  switch (role) {
    case 'staff':
      return 'Staff';
    case 'team_lead':
      return 'Team Lead';
    case 'intern':
      return 'Intern';
    default:
      return role; // fallback
  }
}

String roleToApi(String role) {
  switch (role) {
    case 'Staff':
      return 'staff';
    case 'Team Lead':
      return 'team_lead';
    case 'Intern':
      return 'intern';
    default:
      return role; // fallback
  }
}
