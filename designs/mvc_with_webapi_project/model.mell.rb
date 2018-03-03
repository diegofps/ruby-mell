@{
  validate_presence :model
}
using System.Collections.Generic;

namespace TK_OSS.Model
{
    public class %(model.name)
    {
@if model.requires_constructor?
        public %(model.name)()
        {
  @model.properties.each do |prop|
    @if prop.hasMany?
            %(prop.name) = new List<%(prop.hasMany.name)>();
    @end
  @end
        }

@end
@model.properties.each do |prop|
  @if prop.type == :reference
    @if prop.hasMany?
        public virtual List<%(prop.hasMany.name)> %(prop.name) { get; set; }

    @end
    @if prop.hasOne?
        public virtual %(prop.hasOne.name) %(prop.name) { get; set; }

        public int? %(prop.reference_key) { get; set; }

    @end
  @else
        public %(prop.type) %(prop.name) { get; set; }

  @end
@end
@!
    }
}
