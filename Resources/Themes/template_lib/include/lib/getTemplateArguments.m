(Join@@
  Flatten@{
    #,
    Replace[
      $$templateVars,
      Except[_Association]-><||>
      ],
    Replace[Templating`$TemplateArgumentStack,
      {
          {___,a_}:>a,
          _-><||>
        }
      ]
    })&
