From: Doug Chapman <doug.chapman@hp.com>
Date: Thu, 01 May 2008 15:59:44 +0000
Subject: F9 beta for ia64 now available
Message-Id: <1209657584.1080.14.camel@dchapman.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

= Release notes for F9-beta on ia64 
= Welcome =

Welcome to the F9 beta release Fedora for ia64.  F9 is the
first Fedora release to be officially supported on ia64.  This
ia64 build of fedora is the first to be released under the "secondary
architectures" project.  We have made efforts to make sure that
the ia64 release is equal to the release of Fedora for x86, x86_64,
ppc and ppc64, however there are some differences that should be
noted.

General information on the Fedora-ia64 project can be found at:

http://fedoraproject.org/wiki/Architectures/IA64

For more information about the secondary architectures project
for Fedora see:

http://fedoraproject.org/wiki/Architectures


= Download location =

The beta can be downloaded from:

http://download.fedoraproject.org/pub/fedora-secondary/releases/test/9-Beta/

This will redirect you to one of the available mirrors for this
content.  However, at this point there is only 1 public mirror.
We encourage anyone who managers a public mirror site to mirror
the secondary arch Fedora bits.  Info on how to become a Fedora
mirror can be found at:

http://fedoraproject.org/wiki/Infrastructure/Mirroring

See the section with special information on secondary arch
mirroring.  The mirroring system also allows for setting up
a private mirror only visible to clients connecting from a
specific range of ip addresses (useful for users inside of
large corporations).


= SRPM location =

Since the ia64 release was not done in sync with the other
architectures it does not contain identical versions on all
packages.  Since the fedora MirrorManager assumes that SRPMs
are identical for all arches downloading sources using yumdownloader
will sometimes get a different version of the sources than was
built for ia64.  The entire tree containing binaries and the
exact sources used for this release are kept together in the
tree.

= Bug reporting =

Open source software survives on defect reports from end users.
We would appreciate bugs reports if you find problems.  Bugs
should be filed at:

	http://bugzilla.redhat.com/

Use the component "Fedora" and the version "rawhide" when you
file a bug aginst this beta release.  Please add
fedora-ia64-committee@redhat.com to the CC list so we can
investigate if it is specific to our ia64 build.  Also, please
include the full version of the package that contains the bug
(such as anaconda-11.4.0.75-1 or kernel-2.6.25-1.fc9) since the
versions in the ia64 beta often do not match the version that
was shipped with the beta for other arches.


= No live image =

We do not yet have live DVD images for ia64.  We hope to have
this for Fedora 10.


= Known issues and workarounds =

There are some known issues with this release.  An updated
list along with workarounds can be found at:

http://fedoraproject.org/wiki/Architectures/IA64/Workarounds

Known issues at the time of this writing are:

== Installing using VNC fails =There is no known workaround for this at this time.  You must use
either the text or the normal GUI install under X.


== /boot/efi must be "efi" type not "vfat" =Manually partitioning fails if /boot/efi is selected as
"vfat" filesystem type.  The workaround is to select "efi"
from the list of filesystem types.  This issue is also seen
when trying to reuse an existing /boot/efi partition.  When
re-using an existing /boot/efi partition the installation
will fail unless you specify to reformat it.


== HP Smart Array boot failures =Occasional boot failures on HP Smart Array (aka "cciss")
devices.  This is still under investigation and it is unclear
what the root cause is.  Users who have seen this report
good results by booting with selinux disabled (selinux=0).


== Anaconda crash on HP Smart Array with no disks =When installing on a system that has an HP Smart Array card
that has no disks configured, anaconda will crash.

The workaround is to:

* Step 1: When you get the warning "Unable to determine geometry ..."

choose "Ignore".


* Step 2: When you are asked "The partition table on device cciss/c1d0
was unreadable .... Would you like to initialize this drive,
erasing ALL DATA?"

choose "No"


== Firefox does not run on ia64 =Attempting to run firefox gives the error:

Could not find compatible GRE between version 1.9b5pre and 1.9b5pre.

This has been resolved in the current rawhide tree.  Updating the
browser with "yum update firefox" should resolve this.




