'use client';

import { Fragment, useEffect, useRef, useState } from 'react';
import {
  Dialog,
  DialogBackdrop,
  DialogPanel,
  DialogTitle,
  Transition,
  TransitionChild,
} from '@headlessui/react';
import { Crown, Loader2, ExternalLink, CheckCircle2 } from 'lucide-react';
import { toast } from 'sonner';

const POLL_INTERVAL_MS = 4000;
const POLL_TIMEOUT_MS = 10 * 60 * 1000; // 10 minutes

const UpgradeModal = ({
  isOpen,
  setIsOpen,
  onSuccess,
}: {
  isOpen: boolean;
  setIsOpen: (v: boolean) => void;
  onSuccess?: () => void;
}) => {
  const [loading, setLoading] = useState(false);
  const [polling, setPolling] = useState(false);
  const [paymentUrl, setPaymentUrl] = useState<string | null>(null);
  const pollTimer = useRef<ReturnType<typeof setInterval> | null>(null);
  const timeoutTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  const stopPolling = () => {
    if (pollTimer.current) clearInterval(pollTimer.current);
    if (timeoutTimer.current) clearTimeout(timeoutTimer.current);
    pollTimer.current = null;
    timeoutTimer.current = null;
  };

  const startPolling = () => {
    setPolling(true);

    pollTimer.current = setInterval(async () => {
      try {
        const res = await fetch('/api/subscription/status');
        const data = await res.json();
        if (data.isPremium) {
          stopPolling();
          setPolling(false);
          setPaymentUrl(null);
          setIsOpen(false);
          toast.success('Subscription activated! Welcome to Premium.');
          onSuccess?.();
        }
      } catch {
        // ignore transient errors
      }
    }, POLL_INTERVAL_MS);

    timeoutTimer.current = setTimeout(() => {
      stopPolling();
      setPolling(false);
      toast.error('Payment verification timed out. Please refresh the page.');
    }, POLL_TIMEOUT_MS);
  };

  // Clean up on unmount or modal close
  useEffect(() => {
    if (!isOpen) {
      stopPolling();
      setPolling(false);
      setPaymentUrl(null);
      setLoading(false);
    }
    return () => stopPolling();
  }, [isOpen]);

  const handleUpgrade = async () => {
    setLoading(true);
    try {
      const res = await fetch('/api/subscription/create', { method: 'POST' });
      if (!res.ok) {
        const err = await res.json();
        toast.error(err.error || 'Failed to create subscription');
        return;
      }
      const data = await res.json();
      const url: string = data.paymentUrl;
      setPaymentUrl(url);
      window.open(url, '_blank', 'noopener,noreferrer');
      startPolling();
    } catch (err: any) {
      toast.error(err.message || 'Something went wrong');
    } finally {
      setLoading(false);
    }
  };

  const handleReopenTab = () => {
    if (paymentUrl) {
      window.open(paymentUrl, '_blank', 'noopener,noreferrer');
    }
  };

  return (
    <Transition appear show={isOpen} as={Fragment}>
      <Dialog as="div" className="relative z-50" onClose={() => !polling && setIsOpen(false)}>
        <DialogBackdrop className="fixed inset-0 bg-black/30" />
        <div className="fixed inset-0 overflow-y-auto">
          <div className="flex min-h-full items-center justify-center p-4">
            <TransitionChild
              as={Fragment}
              enter="ease-out duration-200"
              enterFrom="opacity-0 scale-95"
              enterTo="opacity-100 scale-100"
              leave="ease-in duration-100"
              leaveFrom="opacity-100 scale-100"
              leaveTo="opacity-0 scale-95"
            >
              <DialogPanel className="w-full max-w-sm transform rounded-2xl bg-light-secondary dark:bg-dark-secondary border border-light-200 dark:border-dark-200 p-6 text-left shadow-xl transition-all">
                <div className="flex items-center gap-2 mb-1">
                  <Crown size={18} className="text-amber-500" />
                  <DialogTitle className="text-base font-semibold dark:text-white text-black">
                    Upgrade to Premium
                  </DialogTitle>
                </div>

                {!polling ? (
                  <>
                    <p className="text-sm dark:text-white/70 text-black/70 mb-5">
                      Unlock{' '}
                      <span className="text-black dark:text-white font-medium">Deep Research</span>{' '}
                      mode and{' '}
                      <span className="text-black dark:text-white font-medium">GPT 5.2</span>{' '}
                      models.
                    </p>
                    <div className="flex items-center justify-end gap-4">
                      <button
                        onClick={() => setIsOpen(false)}
                        className="text-sm text-black/50 dark:text-white/50 hover:text-black/70 dark:hover:text-white/70 transition duration-200"
                      >
                        Cancel
                      </button>
                      <button
                        onClick={handleUpgrade}
                        disabled={loading}
                        className="flex items-center gap-1.5 text-sm font-medium text-[#24A0ED] hover:text-[#24A0ED]/80 disabled:opacity-50 transition duration-200"
                      >
                        {loading ? (
                          <Loader2 size={14} className="animate-spin" />
                        ) : (
                          <ExternalLink size={14} />
                        )}
                        {loading ? 'Opening...' : 'Subscribe'}
                      </button>
                    </div>
                  </>
                ) : (
                  <>
                    <p className="text-sm dark:text-white/70 text-black/70 mb-4">
                      Complete the payment in the tab that just opened. This dialog will close automatically once your payment is confirmed.
                    </p>
                    <div className="flex items-center gap-2 mb-5 text-sm text-[#24A0ED]">
                      <Loader2 size={14} className="animate-spin shrink-0" />
                      <span>Waiting for payment confirmation…</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <button
                        onClick={handleReopenTab}
                        className="flex items-center gap-1.5 text-sm text-black/50 dark:text-white/50 hover:text-black/70 dark:hover:text-white/70 transition duration-200"
                      >
                        <ExternalLink size={13} />
                        Reopen payment tab
                      </button>
                      <button
                        onClick={() => {
                          stopPolling();
                          setPolling(false);
                          setPaymentUrl(null);
                          setIsOpen(false);
                        }}
                        className="text-sm text-black/40 dark:text-white/40 hover:text-black/60 dark:hover:text-white/60 transition duration-200"
                      >
                        Cancel
                      </button>
                    </div>
                  </>
                )}
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </Transition>
  );
};

export default UpgradeModal;

