From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 30 Jul 2002 00:03:32 +0000
Subject: Re: [Linux-ia64] insmod bug causes kernel unwind failures for module text
Message-Id: <marc-linux-ia64-105590701905849@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905831@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905831@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 25 Jul 2002 13:38:27 -0400, Dave Anderson <anderson@redhat.com> said:

  Dave> There is a bug in the initialization of the unw_table_entry
  Dave> structures for all kernel modules, such that any unwind
  Dave> operation that comes upon a kernel module text address will
  Dave> fail to find its associated unwind info data in the
  Dave> build_script() routine.  (Actually it won't be able to
  Dave> determine what module it belongs to.)

Has this been resolved?

I don't recall seeing any followups.

	--david

