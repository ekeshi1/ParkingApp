defmodule WhiteBreadConfig do
  use WhiteBread.SuiteConfiguration



  context_per_feature namespace_prefix: WhiteBread.Contexts,
                      entry_path: "features/context_per_feature"


  suite name:          "Register",
        context:       WhiteBread.Contexts.RegisterContext,
        feature_paths: ["features/register/"]
  #suite name:          "All",
  #      context:       WhiteBreadContext,
  #      feature_paths: ["features/"]


end
