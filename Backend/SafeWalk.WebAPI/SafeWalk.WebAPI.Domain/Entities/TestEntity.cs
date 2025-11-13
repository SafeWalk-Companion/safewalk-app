using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SafeWalk.WebAPI.Domain.Entities;

[Table("Test")]
public class TestEntity
{
    [Key]
    public int Id { get; set; }

    public string Name { get; set; }
}
