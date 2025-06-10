int generateNotificationId(String id) {
  // Generate a consistent integer ID from the string by hashing it
  return id.hashCode.abs(); // Using absolute value to ensure it's positive
}
