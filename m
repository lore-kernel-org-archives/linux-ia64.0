From: Bill Davidsen <davidsen@tmr.com>
Date: Thu, 27 May 2004 14:54:53 +0000
Subject: Re: Hot plug vs. reliability
Message-Id: <40B6013D.8090704@tmr.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40B5D68C.466FE969@nospam.org> <Pine.LNX.4.53.0405270757250.2487@chaos>
In-Reply-To: <Pine.LNX.4.53.0405270757250.2487@chaos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Zoltan.Menyhart@bull.net, linux-ia64@vger.kernel.org

Richard B. Johnson wrote:
> On Thu, 27 May 2004, Zoltan Menyhart wrote:
> 
> 
>>I've got some questions about how hot plugging can (or cannot)
>>ensure reliability:
>>
>>When we produce machines, we execute tests like burn in, stress,
>>validation, etc. tests. In addition, every time a machine is switched
>>on, a power on self test is executed.
> 
> 
> The POST routine only verifies that some hardware "works" at the
> instant it's tested. It has nothing to do with reliability.
> 
> 
>>When we hot plug (add, remove, swap) a component that has never been
>>seen, how can we make sure that the modified machine achieves the
>>same MTBF as the original machine had, without passing any of the
>>tests I mentioned above ?
>>
> 
> 
> If you want a highly-reliable machine of any type, the components
> are normally burned-in to catch "infant mortality" problems. If
> you "hot-plug" a component, that component should have undergone
> the same kind of burn-in if you wish to maintain some degree
> of reliability. Again a POST routine does not assure anything.
> And, in fact, it's just normally initialization. If you look
> at the stupid, ludicrous, "testing" done in the early IBM/PC
> BIOS, you will understand that it was just some junk that
> some committee decided had to be done, like moving values
> around between CPU registers -- If the CPU didn't work, it
> couldn't test itself -- if the CPU did work, it couldn't
> test itself, etc... Just crap.
> 
> Now, memory testing has some validity because you generally
> need to access it once to get all the bits into a "known"
> state where the charge-pump (refresh) will keep it. However,
> I doubt that much bad memory has actually been detected during
> POST. It's much later, when programs or the kernel crash,
> that bad memory is detected.
> 
> [SNIPPED...]
> 
> So your concern that POST hasn't been run when you hot-plug
> a component isn't a problem. You cannot "test-in" reliability.
> You need to design it in, test it to make sure it's been
> built like it was designed, then burn it in to solve the
> infant mortality problem.

If reliability is your goal, testing at plug time is necessary but not 
sufficient. It avoids kernel failures caused by trying to use devices 
which are disfunctional (the kernel is far better at non-functional than 
broken). And some of the better drivers are far more robust at init time 
than in normal operation, not a bad thing at all. The init code can 
function as POST if it's written to do so.

Testing is a part of the reliability chain, as you note it isn't a 
substitute for all the other parts.

-- 
    -bill davidsen (davidsen@tmr.com)
"The secret to procrastination is to put things off until the
  last possible moment - but no longer"  -me
