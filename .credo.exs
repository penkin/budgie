%{
  configs: [
    %{
      name: "default",
      color: true,
      strict: true,
      checks: [
        {Credo.Check.Design.AliasUsage, false},
        {Credo.Check.Readability.StrictModuleLayout, priority: :low},
        {Credo.Check.Design.TagTODO, false}
      ]
    }
  ]
}
