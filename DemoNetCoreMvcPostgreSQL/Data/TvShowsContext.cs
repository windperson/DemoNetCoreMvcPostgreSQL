using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DemoNetCoreMvcPostgreSQL.Models;
using Microsoft.EntityFrameworkCore;

namespace DemoNetCoreMvcPostgreSQL.Data
{
    public class TvShowsContext : DbContext
    {
        public TvShowsContext(DbContextOptions<TvShowsContext> options) : base(options)
        {
        }

        public DbSet<TvShow> TvShows { get; set; }
    }
}
