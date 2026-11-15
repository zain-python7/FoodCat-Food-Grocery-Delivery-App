enum AppRole { customer, restaurant, rider, admin }
extension RoleLabel on AppRole {
 String get label=>switch(this){AppRole.customer=>'Customer',AppRole.restaurant=>'Restaurant owner',AppRole.rider=>'Delivery rider',AppRole.admin=>'Admin'};
 String get home=>switch(this){AppRole.customer=>'/customer/home',AppRole.restaurant=>'/restaurant/dashboard',AppRole.rider=>'/rider/dashboard',AppRole.admin=>'/admin/overview'};
}
