require File.dirname(__FILE__) + "/../helpers"

class SCMTest < Test::Unit::TestCase
  def scm(uri)
    SCM.new(Addressable::URI.parse(uri), "master", "foo")
  end

  it "recognizes git URIs" do
    scm("git://example.org/repo").should be_an(SCM::Git)
    scm("git@example.org/repo.git").should be_an(SCM::Git)
    scm("git://example.org/repo.git").should be_an(SCM::Git)
  end

  it "recognizes subversion URIs" do
    scm("svn://example.org/repo").should be_an(SCM::Subversion)
    scm("svn://example.org/repo/").should be_an(SCM::Subversion)
    scm("http://example.org/repo/").should be_an(SCM::Subversion)
    scm("https://example.org/repo/").should be_an(SCM::Subversion)
    scm("svn+ssh://example.org/repo/").should be_an(SCM::Subversion)
    scm("file:///repo/").should be_an(SCM::Subversion)
  end

  it "can determine between repository uris" do
    SCM.scm_class_for("git://example.com/repo.git").should == SCM::Git
    SCM.scm_class_for("svn://example.com/repo/").should == SCM::Subversion
  end

  it "raises SCMUnknownError if it can't figure the SCM from the URI" do
    lambda { scm("scm://example.org") }.should raise_error(SCM::SCMUnknownError)
  end

  it "doesn't need the working tree path for all operations, so it's not required on the constructor" do
    lambda {
      SCM.new(Addressable::URI.parse("git://github.com/foca/integrity.git"), "master")
    }.should_not raise_error

    lambda {
      SCM.new(Addressable::URI.parse("svn://example.com/repo/"), "master")
    }.should_not raise_error
  end

  describe "SCM::URI" do
    git_uris = [
      "rsync://host.xz/path/to/repo.git/",
      "rsync://host.xz/path/to/repo.git",
      "rsync://host.xz/path/to/repo.gi",
      "http://host.xz/path/to/repo.git/",
      "https://host.xz/path/to/repo.git/",
      "git://host.xz/path/to/repo.git/",
      "git://host.xz/~user/path/to/repo.git/",
      "ssh://[user@]host.xz[:port]/path/to/repo.git/",
      "ssh://[user@]host.xz/path/to/repo.git/",
      "ssh://[user@]host.xz/~user/path/to/repo.git/",
      "ssh://[user@]host.xz/~/path/to/repo.git",
      "host.xz:/path/to/repo.git/",
      "host.xz:~user/path/to/repo.git/",
      "host.xz:path/to/repo.git",
      "user@host.xz:/path/to/repo.git/",
      "user@host.xz:~user/path/to/repo.git/",
      "user@host.xz:path/to/repo.git",
      "user@host.xz:path/to/repo",
      "user@host.xz:path/to/repo.a_git",
    ]

    uris.each do |uri|
      it "parses the git_uri #{uri}" do
        git_url = SCM::URI.new(uri)
        git_url.working_tree_path.should == "path-to-repo"
      end
    end

    svn_uris = [
      "svn://host.xz/path/to/repo/",
      "svn://host.xz/path/to/repo",
      "http://host.xz/path/to/repo",
      "http://host.xz/path/to/repo/",
      "https://host.xz/path/to/repo",
      "https://host.xz/path/to/repo/",
      "file:///path/to/repo/",
      "file:///path/to/repo",
      "svn+ssh://host.xz/path/to/repo",
      "svn+ssh://host.xz/path/to/repo/"
    ]
    uris.each do |uri|
      it "parses the svn uri #{uri}" do
        svn_url = SCM::URI.new(uri)
        svn_url.working_tree_path.should == "path-to-repo"
      end
    end
  end
end

