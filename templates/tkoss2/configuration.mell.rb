using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.Infrastructure.Annotations;
using System.Data.Entity.ModelConfiguration;
using TK_OSS.Model;

namespace TK_OSS.Data.Configuration
{
    public class %(model)Configuration: EntityTypeConfiguration<%(model)>
    {
        public %(model)Configuration()
        {
          @query.type(model, :name, :basic_type) do |name, basic_type|
            @if basic_type != 'reference'
              @query.type(model, :name, basic_type) do |name, type|
                @if query.pk(model, name).valid?
            HasKey(x => x.%(name));
                @end
            Property(x => x.%(name))
                @if query.pk(model, name).valid?
                .HasDatabaseGeneratedOption(DatabaseGeneratedOption.Identity)
                @elsif query.isUnique(model, name).valid?
                .HasColumnAnnotation("Index", new IndexAnnotation(new IndexAttribute() { IsUnique = true }))
                @elsif query.hasIndex(model, name).valid?
                .HasColumnAnnotation("Index", new IndexAnnotation(new IndexAttribute()))
                @end
              @!;

              @end
            @end
          @end
          @query.plural(model, :plural).hasMany(:other, :prop_name, :plural) do |other, prop_name, plural|
            HasRequired(x => x.%(prop_name))
                .WithMany(y => y.%(other))
                .HasForeignKey(x => x.%(prop_name)Id)
            @if query.cascadeDelete(other, prop_name).valid?
                .WillCascadeOnDelete(true)
            @else
                .WillCascadeOnDelete(false)
            @end
            @!;
          @end

          @{
            #Property(x => x.Nome).HasMaxLength(50);
          }
          @!
        }
    }
}
