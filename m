From: Ulrich Drepper <drepper@redhat.com>
Date: Thu, 22 Mar 2001 01:13:03 +0000
Subject: [Linux-ia64] Re: sprofil() implementation
Message-Id: <marc-linux-ia64-105590693005331@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005326@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005326@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

> Yes, I considered that.  I thought it would be OK to use sprofil() to
> stop profiling completely on a dlopen(), register the new library, and
> then call sprofil() again.  Apart from being a bit slower than
> strictly necessary, I don't think there is an issue with this.  Are
> you concerned about performance or something else?

Multi-threaded applications will have a problem with this.  I prefer
to see a possibility to actually add and remove segments.

> On a related topic: the gmon.out file currently does not encode any
> filenames.  That's would create problems with dlopen().  I think the
> best way to fix this is to add a new gmon.out tag that encodes the
> filename to which the remainder of the file applies
> (GMON_TAG_IMAGE_PATH or something like that).

Definitely, there are quite a lot of changes necessary to the gmon
format.  I haven't even started thinking about this.

-- 
---------------.                          ,-.   1325 Chesapeake Terrace
Ulrich Drepper  \    ,-------------------'   \  Sunnyvale, CA 94089 USA
Red Hat          `--' drepper at redhat.com   `------------------------

