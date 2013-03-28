From: Tony Luck <tony.luck@gmail.com>
Date: Thu, 28 Mar 2013 20:21:18 +0000
Subject: Re: [PATCH][RESEND] [IA64] tiocx: check retval from bus_register()
Message-Id: <CA+8MBbLkqb5ZEGcX117erfe330JfiGmz8xAjo2+EkYs6FaqRRg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LNX.2.00.1303191035010.9529@pobox.suse.cz>
In-Reply-To: <alpine.LNX.2.00.1303191035010.9529@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 27, 2013 at 6:19 AM, Jiri Kosina <jkosina@suse.cz> wrote:
> Is anyone please going to apply/nack this, please?

Sorry - I didn't send an "applied" message. I picked this up last week
and it is in my "next" tree and linux-next as:

commit d7c6797fbc2c2efa7573817685d2a76fd274d2de
Author: Jiri Kosina <jkosina@suse.cz>
Date:   Tue Mar 19 10:36:13 2013 +0100

    tiocx: check retval from bus_register()

-Tony
