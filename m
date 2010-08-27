From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 27 Aug 2010 16:37:08 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <201008271837.10014.ptesarik@suse.cz>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_2m+dMnDsSqTIwWo"
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <201008271640.49542.ptesarik@suse.cz> <20100827145231.GZ18967@zorg.emea.sgi.com>
In-Reply-To: <20100827145231.GZ18967@zorg.emea.sgi.com>
To: Hedi Berriche <hedi@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

--Boundary-00=_2m+dMnDsSqTIwWo
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday 27 of August 2010 16:52:31 Hedi Berriche wrote:
> On Fri, Aug 27, 2010 at 15:40 Petr Tesarik wrote:
> | On Friday 27 of August 2010 16:31:35 Hedi Berriche wrote:
> | > That said, I'm letting my already over 36 hours run carry on chewing
> | > CPU time, and see if it will eventually trip the same problem seen with
> | > 4-byte ticket locks.
> |
> | Hm, this doesn't sound like a viable approach. Since the siglock gets
> | initialized to 0 when a new process is started, it may never actually
> | wrap around.
> |
> | I would rather attach a SystemTap probe somewhere during process fork and
> | add a bias to the siglock. That should work fine. Let me knock up the
> | SystemTap script...
>
> That would be nice. Ta!

Here it is. I don't have a system with the old 64-bit ticket spinlocks at 
hand, so this is completely untested, but it should work fine.

Adjust if needed.

Petr

--Boundary-00=_2m+dMnDsSqTIwWo
Content-Type: text/x-csrc;
  charset="iso 8859-15";
  name="biaslock.stp"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="biaslock.stp"

/* Bias the spin lock on fork */

%{
#define LOCK_BIAS ((1ULL << 32) - (1ULL << 15))
%}

function bias_siglock (task:long)
%{
	struct task_struct *tsk = (struct task_struct*)THIS->task;
	tsk->sighand->siglock.raw_lock.lock = LOCK_BIAS + (LOCK_BIAS << 32);
%}

function is_err (value:long)
%{
	THIS->__retvalue = IS_ERR_VALUE((unsigned long)THIS->value);
%}

probe kernel.function("copy_process").return
{
	if (!is_err($return))
		bias_siglock($return);
}

--Boundary-00=_2m+dMnDsSqTIwWo--
