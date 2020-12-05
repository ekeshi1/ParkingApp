defmodule WhiteBreadConfig do
  use WhiteBread.SuiteConfiguration



  context_per_feature namespace_prefix: WhiteBread.Contexts,
                      entry_path: "features/context_per_feature"


#   suite name:          "Register",
#          context:       WhiteBread.Contexts.RegisterContext,
#          feature_paths: ["features/register/"]

#   suite name:          "Login",
#          context:       WhiteBread.Contexts.LoginContext,
#          feature_paths: ["features/login/"]

  suite name:          "Search",
        context:       WhiteBread.Contexts.SearchParkingContext,
       feature_paths: ["features/searchparking/"]

#   suite name:          "Parking Booking",
#         context:       WhiteBread.Contexts.ParkingBookingContext,
#         feature_paths: ["features/book/"]

#   suite name:          "Terminate Parking",
#         context:       WhiteBread.Contexts.TerminateParkingContext,
#         feature_paths: ["features/terminateparking/"]

  # suite name:          "Extend Parking",
  #       context:       WhiteBread.Contexts.ExtendBookingContext,
  #       feature_paths: ["features/extendbooking/"]
        #suite name:          "All",
  #      context:       WhiteBreadContext,
  #      feature_paths: ["features/"]


end
