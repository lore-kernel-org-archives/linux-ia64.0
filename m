From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 21 Mar 2001 22:00:27 +0000
Subject: [Linux-ia64] Re: sprofil() implementation
Message-Id: <marc-linux-ia64-105590693005328@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005326@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005326@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 21 Mar 2001 12:17:30 -0800, Ulrich Drepper <drepper@redhat.com> said:

  Uli> David Mosberger <davidm@hpl.hp.com> writes:
  >> Attached below is an implementation of the sprofil() call.

  Uli> Thanks, I've added the patch.  There was one bug left (on 32-bit
  Uli> archs) and I did some reformatting but essentially it is plainly
  Uli> accepted.  Thanks.

Thanks!

  Uli> But one word of warning: this interface is insufficient.  We need a
  Uli> way to dynamically add and remove new segments.  This is necessary to
  Uli> support dlopen() etc.

Yes, I considered that.  I thought it would be OK to use sprofil() to
stop profiling completely on a dlopen(), register the new library, and
then call sprofil() again.  Apart from being a bit slower than
strictly necessary, I don't think there is an issue with this.  Are
you concerned about performance or something else?

On a related topic: the gmon.out file currently does not encode any
filenames.  That's would create problems with dlopen().  I think the
best way to fix this is to add a new gmon.out tag that encodes the
filename to which the remainder of the file applies
(GMON_TAG_IMAGE_PATH or something like that).

	--david

