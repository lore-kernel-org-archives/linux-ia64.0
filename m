From: Jes Sorensen <jes@wildopensource.com>
Date: Wed, 19 Mar 2003 21:39:31 +0000
Subject: [Linux-ia64] provide /proc/sal/itc_drift through AUX?
Message-Id: <marc-linux-ia64-105590723705273@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi

I was wondering what people think about providing the information of
/proc/sal/itc_drift as an AUX vector?

The problem is that on some NUMA boxen (such as the SGI boxes), the ITC
isn't synchronized across nodes and we can't rely on ar.itc in userland
for implementing the high-precision timing. I believe the IBM NUMA-Q
team has a similar problem that could be solved in a similar way on
ia32?

Instead one can switch to using gettimeofday() for the timing, which
with the new fast syscalls should be quite pleasant.

I have a patch which implements this for glibc-2.2 (will do 2.3 later),
however what I don't like about it is that one ends up opening and
reading /proc/sal/itc_drift in every single binary executed. To avoid
the overhead of this it seems a good idea to me to provide this
information via an AUX vector.

If anybody is interested in the glibc patch, feel free to grab it from
http://www.wildopensource.com/~jes/glibc/itc-drift-patch.diff
For now it's a test patch, though it does seem to behave as expected.

Thoughts?

Cheers,
Jes

