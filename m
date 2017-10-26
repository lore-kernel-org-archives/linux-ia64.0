From: John Stultz <john.stultz@linaro.org>
Date: Thu, 26 Oct 2017 18:43:19 +0000
Subject: Re: GENERIC_TIME_VSYSCALL_OLD deprecation
Message-Id: <CALAqxLXE5YdVgZzBU8DAYXHPqtrycmaoNQtkuZM8G_o5RxgJbg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CALAqxLWesBREQ5+8dbzYuofRJfkzQEbxYD-f5hT4xTJ7khJoEg@mail.gmail.com>
In-Reply-To: <CALAqxLWesBREQ5+8dbzYuofRJfkzQEbxYD-f5hT4xTJ7khJoEg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 25, 2017 at 5:29 PM, Luck, Tony <tony.luck@intel.com> wrote:
>>  I was hoping I could drop CONFIG_GENERIC_TIME_VSYSCALL_OLD for 4.15,
>> but it seems like ia64 hasn't updated its fsyscall implementation yet?
>>
>> I had a rough try at fixing this awhile back:
>> http://patches.linaro.org/patch/30501/
>>
>> But I've not heard much.
>
> Sorry, I've been a bad maintainer.  I'm travelling internationally this week
> but I will take a look at your proposed patch next week.

I feel the same way, often :)

Thanks for checking it out. I'll hold off on pushing the break to 4.15
but will queue it up for 4.16.

thanks
-john
