using System.ComponentModel.DataAnnotations;

namespace Fintech_Test_.Model
{
    public class Links
    {
        [Key]
        public long LinkId { get; set; }
        public long? UpProductId { get; set; }
        public long ProductId { get; set; }
        public int Count { get; set; }

        public Product? Product { get; set; }
        public Product? UpProduct { get; set; }
    }
}
