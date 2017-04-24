@{
  validate_presence :model
}
using System.Collections.Generic;

namespace TK_OSS.Model
{
    public class %(model)
    {
@if query.requires_constructor(model).valid?
        public %(model)()
        {
  @query.hasMany(model, :prop, :plural).plural(:other, :plural) do |prop, plural, other|
            %(plural) = new List<%(other)>();
  @end
        }

@end
@query.type(model, :prop_name, :type) do |prop_name, type|
  @if type == 'reference'
    @query.hasMany(model, prop_name, :other_plural).plural(:other, :other_plural) do |other_plural, other|
        public virtual List<%(other)> %(prop_name) { get; set; }

    @end
    @query.hasOne(model, prop_name, :other) do |other|
        public virtual %(other) %(prop_name) { get; set; }

    @end
  @else
        public %(type) %(prop_name) { get; set; }

  @end
@end
@query.plural(model, :plural).hasMany(:other, :prop_name, :plural) do |plural, other, prop_name|
        public virtual %(other) %(other) { get; set; }

        public int? %(other)Id { get; set; }

@end
@query.hasOne(:other, :prop_name, model) do |other, prop_name|
        public virtual %(other) %(other) { get; set; }

        public int? %(other)Id { get; set; }

@end
@!
    }
}
