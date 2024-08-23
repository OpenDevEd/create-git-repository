#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use File::Path qw(make_path);
use Cwd;

# Function to write text to a file
sub write_text {
    my ($filename, $content) = @_;
    open my $fh, '>', $filename or die "Could not open file '$filename': $!";
    print $fh $content;
    close $fh;
}

# Function to run system commands and check for errors
sub run_command {
    my ($command) = @_;
    system($command) == 0 or die "Failed to execute: $command\n";
}

# Parse command line options
my $private = 0;
my $description = "";
GetOptions(
    "private" => \$private,
    "description=s" => \$description
) or die "Error in command line arguments\n";

# Get repository name
my $reponame = shift @ARGV or die "Please provide a repository name\n";
$reponame =~ s/\s/_/g;  # Replace spaces with underscores

# Create directory for the new repository
my $repo_dir = getcwd() . "/$reponame";
make_path($repo_dir) or die "Failed to create directory $repo_dir: $!";
chdir $repo_dir or die "Cannot change to directory $repo_dir: $!";

# Initialize git repository
run_command("git init");

# Create README.md
write_text("README.md", "# $reponame\n\n$description");

# Create .gitignore
write_text(".gitignore", "*.log\n.DS_Store\nnode_modules/\n");

# Create GitHub repository
my $private_flag = $private ? "--private" : "--public";
run_command("gh repo create OpenDevEd/$reponame $private_flag --description \"$description\" --source=. --remote=origin");

# Add files, commit, and push
run_command("git add README.md .gitignore");
run_command("git commit -m \"Initial commit\"");
run_command("git branch -M main");
run_command("git push -u origin main");

# Open repository settings in browser
run_command("xdg-open https://github.com/OpenDevEd/$reponame/settings/access");

print "Repository '$reponame' created successfully!\n";