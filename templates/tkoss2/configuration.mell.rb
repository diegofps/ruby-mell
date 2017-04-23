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
          @['int', 'int?', 'string', 'DateTime', 'DateTime?', 'blob', 'blob?'].each do |basic_type|
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
          @{
            #Property(x => x.Nome).HasMaxLength(50);

            #HasRequired(x=> x.Cidade).WithMany(cid => cid.Bairros).HasForeignKey(x => x.CidadeId).WillCascadeOnDelete(false);
          }
          @!
        }
    }
}
