From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Feb 2003 19:52:30 +0000
Subject: Re: [Linux-ia64] RE: ia64 rwsem using atomic primitive
Message-Id: <marc-linux-ia64-105590709805877@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805873@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805873@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Feb 2003 10:31:33 -0800, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> Here is a patch against 2.5.60.  It has one new function added
  Ken> __downgrade_write() for 2.5.  - Ken

I glanced over the patch and it looks fine, except that it has CR-LF
for end-of-line.  Could you resend with the carriage-returns removed?

Thanks,

	--david


