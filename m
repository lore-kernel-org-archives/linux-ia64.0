From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 22 Dec 2004 13:38:28 +0000
Subject: n-way sampling buffer format for perfmon2
Message-Id: <20041222133828.GB28622@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello All,

I have released a first prototype of a sampling buffer format
which implements a n-way buffer. Many tool developers have
asked me for a sampling buffer which would do double or
even triple buffering. The idea is to split the buffer
in sections. A notification is sent to the tool
when one section fills up and in the meantime continue to record
samples in the other sections. If timing works out, monitoring
will never stop, i.e. achieving fulltime coverage. 
Of course, the downside is that if monitoring continues, you may
capture noise caused by the monitoring tool. It is not a systematic
win and experimentation is important. In any case, one would
think this is interesting in system-wide where it is obviously
not possible to "freeze" the system while processing the buffer. 
The format supports both system-wide and per-thread modes.

This new buffer format is a simple kernel module that plugs into
the perfmon infrastructure. It is a perfect example of the power
of the interface. Not a single change is needed in the perfmon core
to use this buffer format. The default format is still available.

Because the number of ways in the buffer depends on what you measure
and how you measure, the format is very flexible in that it lets you
choose dynamically the number of ways from 1 to 8. The structure
of each sample is identical to the default sampling format, as such
it is fairly easy to migrate existing code to this format.

If people find this format useful, I will be glad to include it into
the standard kernel.

The package comes with the kernel module, the module header file and
a very simple example with lots of comments showing the various features
of the format and how to parse the samples. You need at least 2.6.5
to use this new format.

You can grab the tarfile for the package at:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/nway_smpl-0.1.tar.gz
	MD5SUM: 7279cad500aca6779917cf63781dcd71

Enjoy,

-- 
-Stephane
