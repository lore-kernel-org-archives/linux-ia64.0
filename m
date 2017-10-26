From: John Stultz <john.stultz@linaro.org>
Date: Thu, 26 Oct 2017 00:07:08 +0000
Subject: GENERIC_TIME_VSYSCALL_OLD deprecation
Message-Id: <CALAqxLWesBREQ5+8dbzYuofRJfkzQEbxYD-f5hT4xTJ7khJoEg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hey folks,
  I was hoping I could drop CONFIG_GENERIC_TIME_VSYSCALL_OLD for 4.15,
but it seems like ia64 hasn't updated its fsyscall implementation yet?

I had a rough try at fixing this awhile back:
http://patches.linaro.org/patch/30501/

But I've not heard much.

The recent addition of build warnings hasn't seemed to motivate much either.

I'd rather not break ia64 from building with a future patch, but I've
been sitting on some changes that depend on the VSYSCALL_OLD code
going away for awhile now.

Any chance this could be addressed?

thanks
-john
