From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 08 Jun 2001 20:03:38 +0000
Subject: RE: [Linux-ia64] 2.4.5 hangs in smp_call_function.
Message-Id: <marc-linux-ia64-105590693005703@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005699@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005699@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Actually, I'd like to remove support for anything older than B3 in the
not too distant future.  I can leave the code there for a while
longer, but I'm considering it unsupported.  Also, note that this
means that if you find a bug that shows up only on pre-B3 systems, I
don't care about it and don't want to hear about it... ;-)

	--david

>>>>> On Fri, 8 Jun 2001 11:49:55 -0700, "Seth, Rohit" <rohit.seth@intel.com> said:

  Rohit> Jack, The only change that is needed is to change the value
  Rohit> of timeout from HZ to 400...  The race condition where source
  Rohit> processor is getting out of while (timeout) loop and target
  Rohit> processor is just about to send the acknowledgement (by
  Rohit> setting the started field) will most likely not happen for
  Rohit> such a big timeout. And as this code is only for earlier
  Rohit> stepping so it should be okay.  Though I think that HZ itself
  Rohit> is big enough but then seems like your system is under severe
  Rohit> load and taking longer to respond for IPIs.

  Rohit> Besides that the other changes are not needed.  In fact there
  Rohit> are couple of things that you should not do 1: don't include
  Rohit> resend_list_IPI even when CONFIG_ITANIUM_PTCG is defined 2:
  Rohit> don't just continue to be in while loop without resending the
  Rohit> IPI again for the cases when you really have a lost IPI.

