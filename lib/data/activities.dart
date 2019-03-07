class Activity {
  Activity({this.id, this.name, this.units, this.icon});

  final String name;
  final String units;
  final String id;
  final String icon;
}

final List<Activity> activities = [
  Activity(id: 'benchpress', name: 'Bench Press', units: 'Pounds', icon: 'ic_benchpress'),
  Activity(id: 'bicepcurls', name: 'Bicep Curls', units: 'Reps', icon: 'ic_bicepcurls'),
  Activity(id: 'lunges', name: 'Lunges', units: 'Lunges', icon: 'ic_lunges'),
  Activity(id: 'plank', name: 'Plank', units: 'Seconds', icon: 'ic_plank'),
  Activity(id: 'squats', name: 'Squats', units: 'Squats', icon: 'ic_squats'),
  Activity(id: 'running', name: 'Running', units: 'Kilometres', icon: 'ic_running'),
  Activity(id: 'pushups', name: 'Pushups', units: 'Pushups', icon: 'ic_pushups'),
];

Activity getActivity(String id) {
  return activities.where((activity) => activity.id == id).first;
}