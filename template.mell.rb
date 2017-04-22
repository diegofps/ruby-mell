@{
  #puts "It works! I guess.. :)"
}
public class %(entity)
{
@if 1 == 1

    public %(entity)()
    {
      @constructor.each do |plural, other|
        %(plural) = new List<%(other)>();
      @end
    }
@end
@properties.each do |prop, type|
  @if type == 'reference'

    public int %(prop)Id { get; set; }

    public virtual %(prop) %(prop) { get; set; }
  @else

    %{"Diego\nFonseca\nPereira de\nSouza"}
    public %(type) %(prop) { get; set; }
  @end
@end

}
