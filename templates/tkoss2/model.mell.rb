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
@query.type(model, :prop, :type) do |prop, type|
  @if type == 'reference'
    @query.plural(:other, prop) do |other|
        public int %(prop)Id { get; set; }

        public virtual List<%(other)> %(prop) { get; set; }

    @end
  @else
        public %(type) %(prop) { get; set; }

  @end
@end
@!
    }
}
