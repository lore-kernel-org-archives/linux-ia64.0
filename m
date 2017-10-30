From: John Stultz <john.stultz@linaro.org>
Date: Mon, 30 Oct 2017 23:31:37 +0000
Subject: Re: GENERIC_TIME_VSYSCALL_OLD deprecation
Message-Id: <CALAqxLWs3CZGY3DNqkUS66KnohAZaYwKf1Di5j7RFD5gnXHyww@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CALAqxLWesBREQ5+8dbzYuofRJfkzQEbxYD-f5hT4xTJ7khJoEg@mail.gmail.com>
In-Reply-To: <CALAqxLWesBREQ5+8dbzYuofRJfkzQEbxYD-f5hT4xTJ7khJoEg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 30, 2017 at 4:25 PM, Luck, Tony <tony.luck@intel.com> wrote:
> On Thu, Oct 26, 2017 at 11:43:19AM -0700, John Stultz wrote:
>> > Sorry, I've been a bad maintainer.  I'm travelling internationally this week
>> > but I will take a look at your proposed patch next week.
>>
>> I feel the same way, often :)
>>
>> Thanks for checking it out. I'll hold off on pushing the break to 4.15
>> but will queue it up for 4.16.
>
> Well this would have been a whole lot easier if I had taken your
> proto-patch three years ago. It seems that almost all the fields of
> "struct timekeeper" changed since then!

Apologies!

> Here's what I'm running tests with. If you could run an eye over it to
> make sure I didn't do something odd or miss something when cut&pasting
> code from arch/x86 I'd appreciate it.
>
> The new "struct time_sn_spec" is to keep the secs/snsecs bundled at
> known offsets from each other to preserve more of the assembly code
> ... otherwise I'd have had to find another scratch register to save
> the offset of the snsecs separately from the offset of the secs (or put
> flashing tag comments in the header file to say that snsecs must stay
> right after secs).


From the quick skim it looks sane to me.

I'd recommend running the kselftest/timers tests to help validate what
you have.

Be sure to use the "make run_destructive_tests" variant, as folks
often miss that one.
(And make sure you have ntpd/chrony/systemd-timesync turned off while
the tests are running)

thanks
-john
