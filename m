From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 14 Nov 2002 15:47:34 +0000
Subject: [Linux-ia64] RE: memcpy failure
Message-Id: <marc-linux-ia64-105590709805428@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805424@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805424@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

I was thinking along the same line as returning void for memcpy.  And that is what implemented in memcpy_mck.S. r8 is initialized to zero in the code path mainly for copy_user.

I suppose I should follow the convention since everyone except me expect memcpy to return dest pointer and actually use the return value ;-)  I can work on that although I need to shuffle some instruction around to avoid  expand the code size and worsen the copy throughput.

- Ken


-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Wednesday, November 13, 2002 9:52 PM
To: Chen, Kenneth W
Cc: Christian Cotte-Barrot; David Mosberger; Stephane Eranian
Subject: RE: memcpy failure


>>>>> On Tue, 12 Nov 2002 10:29:23 -0800, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> The retrun value for memcpy doesn't follow the user space
  Ken> memcpy exactly.  kernel memcpy always return 0.

Why are you saying this?  As far as I know, the kernel memcpy() is
expected to return the (initial) destination address.  Perhaps you're
thinking of copy_user()?

(If it was up to me, memcpy() would be returning void...).

	--david

