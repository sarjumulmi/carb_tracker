Handlebars.registerHelper('select_list', function(select_options, id) {
  var template = HandlebarsTemplates['recipes/foods_select'];

  var list = $.map(select_options, function(e) {
    if (id === e.id){
      e.selected = "selected";
      return e;
    } else {
      return e;
    }
  });

  return new Handlebars.SafeString(template(list));
});

Handlebars.registerHelper('num', function(number) {
  return number.toFixed(1).toLocaleString();
});

Handlebars.registerHelper('title', function(string) {
  return string.titleize();
});

