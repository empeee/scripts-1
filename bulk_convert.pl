#!/usr/bin/perl

#===============================================
# Name: bulk_convert.pl
# Author: Kevin Fronczak
# Date: Jan 2, 2017
# Desc: Converts all files in a directory with
#       a given extension to an eps file
#
# CHANGELOG:
#   v0.1: Initial revision (2017-01-02 KF)
#===============================================

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use File::Find;
use File::Basename;
use File::Path qw/make_path/;

my $man     = 0;
my $help    = 0;
my $verbose = 0;
my $force   = 0;
my $all     = 0;
my $dest    = '';

GetOptions('verbose' => \$verbose,
           'force'   => \$force,
           'dest=s'  => \$dest,
           'help|?'  => \$help,
           man       => \$man) or pod2usage(2);

pod2usage(2) if $help;
pod2usage(-exitval => 0, -verbose => 2) if $man;


unless( $#ARGV == 1)
{
  die "\nERROR: Not enough arguments\nUsage: bulk_convert [opts] <ext> <dir>\nUse '-man' option for more info\n";
}

my $ext = $ARGV[0];
my $dir = $ARGV[1];

# Create bceps directory if needed
if ( $dest eq '')
{
  $dest = $ENV{"HOME"} . "/bceps";
  unless( -e $dest or mkdir $dest)
  {
    die "Unable to create $dest\n";
  }
}

if ($verbose)
{
  print("Looking for files with .$ext ");
  if ($all)
  {
    print("recursively ");
  }
  print("in $dir and saving to $dest\n");
}

# Create a list of files in directory
my @filesToConvert;
find({wanted => \&find_file, no_chdir=>1}, $dir);


foreach my $file (@filesToConvert)
{
  my $newFile = $file;
  $newFile =~ s/^$dir//;      # removes base directory from beginning of file name
  $newFile =~ s/$ext$/eps/;   # Appends new file with .eps instead of .<ext>
  $newFile = $dest.$newFile;
    
  my $newDir = dirname($newFile);
  
  if (! -f $newFile)
  {
  
    unless(-e $newDir or make_path($newDir))
    {
      die "Unable to create $newDir\n";
    }
    
    if ($verbose) { print "Converting $file ... "; }
    system("convert $file eps2:$newFile");
    if ($verbose) { print "Done \n"; }
  }
  else
  {
    if ($verbose) { print "Skipping $file\n"; }
  }
}

print "Conversion complete!\n\n";


# Routine to find file
sub find_file {
  my $file = $File::Find::name;
  
  if ($file =~ /$ext$/)
  {
    push @filesToConvert, $file;
  }
}

__END__
#===============================================
# MAN PAGE
#===============================================
=head1 NAME

bulk_convert.pl

=head1 SYNOPSIS

bulk_convert [options] <extension> <directory>

Options:
  --force         
  --dest=<dir>    
  --verbose       
  
=head1 OPTIONS

=over 4

=item B<--dest>

Custom destination for converted files (defaults to /home/$USER/bceps)

=item B<--verbose>

Prints all files being converted to terminal

=item B<--force>

Forces file overwrite if it already exists

=back

=head1 DESCRIPTION

B<bulk_convert> will convert all files with a given [extension] in [directory] and change them to eps files.

For example:

  bulk_convert.pl -r --dest=./images png /my/dir/of/images
  
This command will recursively traverse the /my/dir/of/images directory (images and all children) and find all files ending in ".png".  It will then convert all these files and place them into the ./images directory (the script will preserve hieararchy)

=cut
