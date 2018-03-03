using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.Infrastructure.Annotations;
using System.Data.Entity.ModelConfiguration;
using TK_OSS.Model;

namespace TK_OSS.Data.Configuration
{
    public class %(model.name.camel)Configuration: EntityTypeConfiguration<%(model.name.camel)>
    {
        public %(model.name.camel)Configuration()
        {
          @model.properties.each do |prop|
            //%(prop._id)
            @if prop.type != :reference
              @if prop.pk?
            HasKey(x => x.%(prop.name));
              @end
            Property(x => x.%(prop.name))
              @if prop.pk?
                .HasDatabaseGeneratedOption(DatabaseGeneratedOption.Identity)
              @elsif prop.isUnique?
                .HasColumnAnnotation("Index", new IndexAnnotation(new IndexAttribute() { IsUnique = true }))
              @elsif prop.hasIndex?
                .HasColumnAnnotation("Index", new IndexAnnotation(new IndexAttribute()))
              @end
              @!;

            @else
            HasRequired(x => x.%(prop.name))
                .WithMany(y => y.%(prop.brother.name))
                .HasForeignKey(x => x.%(prop.reference_key))
              @if prop.cascadeDelete?
                .WillCascadeOnDelete(true)
              @else
                .WillCascadeOnDelete(false)
              @end
              @!;
            @end
          @end
          @{
            #Property(x => x.Nome).HasMaxLength(50)
          }
          @!
        }
    }
}
