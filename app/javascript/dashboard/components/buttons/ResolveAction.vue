<script setup>
import { ref, computed } from 'vue';
import { useAlert } from 'dashboard/composables';
import { useToggle } from '@vueuse/core';
import { useI18n } from 'vue-i18n';
import { useAdmin } from 'dashboard/composables/useAdmin';
import { useStore, useStoreGetters } from 'dashboard/composables/store';
import { useEmitter } from 'dashboard/composables/emitter';
import { useUISettings } from 'dashboard/composables/useUISettings';
import { useKeyboardEvents } from 'dashboard/composables/useKeyboardEvents';
import { FEATURE_FLAGS } from 'dashboard/featureFlags';

import WootDropdownItem from 'shared/components/ui/dropdown/DropdownItem.vue';
import WootDropdownMenu from 'shared/components/ui/dropdown/DropdownMenu.vue';
import wootConstants from 'dashboard/constants/globals';
import {
  CMD_REOPEN_CONVERSATION,
  CMD_RESOLVE_CONVERSATION,
} from 'dashboard/helper/commandbar/events';

const store = useStore();
const getters = useStoreGetters();
const { updateUISettings } = useUISettings();
const { t } = useI18n();

const arrowDownButtonRef = ref(null);
const isLoading = ref(false);

const [showActionsDropdown, toggleDropdown] = useToggle();
const closeDropdown = () => toggleDropdown(false);
const openDropdown = () => toggleDropdown(true);

const currentChat = computed(() => getters.getSelectedChat.value);
const accountId = computed(() => getters.getCurrentAccountId.value);
const isFeatureEnabledonAccount = computed(() => getters['accounts/isFeatureEnabledonAccount'](accountId.value));

const { isAdmin } = useAdmin();

const isOpen = computed(
  () => currentChat.value.status === wootConstants.STATUS_TYPE.OPEN
);
const isPending = computed(
  () => currentChat.value.status === wootConstants.STATUS_TYPE.PENDING
);
const isResolved = computed(
  () => currentChat.value.status === wootConstants.STATUS_TYPE.RESOLVED
);
const isSnoozed = computed(
  () => currentChat.value.status === wootConstants.STATUS_TYPE.SNOOZED
);
const isClosed = computed(
  () => currentChat.value.closed
);
const canCloseConversation = computed(() => {
  return isAdmin && isResolved && !isClosed;
});
const canUncloseConversation = computed(() => {
  return isAdmin && isResolved && isClosed;
});

const buttonClass = computed(() => {
  if (isPending.value) return 'primary';
  if (isOpen.value) return 'success';
  if (isResolved.value) return 'warning';
  return '';
});

const showAdditionalActions = computed(
  () => !isPending.value && !isSnoozed.value
);

const inbox = computed(() => getters['inbox/getInbox'](currentChat.value.inbox_id));
const enabledRequiredContactType = computed(() => {
  return isFeatureEnabledonAccount(
    accountId.value,
    FEATURE_FLAGS.REQUIRED_CONTACT_TYPE
  )
});

const showOpenButton = computed(() => {
  return isPending.value || isSnoozed.value;
});

const getConversationParams = () => {
  const allConversations = document.querySelectorAll(
    '.conversations-list .conversation'
  );

  const activeConversation = document.querySelector(
    'div.conversations-list div.conversation.active'
  );
  const activeConversationIndex = [...allConversations].indexOf(
    activeConversation
  );
  const lastConversationIndex = allConversations.length - 1;

  return {
    all: allConversations,
    activeIndex: activeConversationIndex,
    lastIndex: lastConversationIndex,
  };
};

const openSnoozeModal = () => {
  const ninja = document.querySelector('ninja-keys');
  ninja.open({ parent: 'snooze_conversation' });
};

const toggleStatus = (status, snoozedUntil) => {
  closeDropdown();

  if (inbox.value?.label_required && status === wootConstants.STATUS_TYPE.RESOLVED) {
    if (currentChat.value?.labels.length === 0) {
      useAlert(t('CONVERSATION.LABEL_REQUIRED'));
      showContactSidebar();
      return;
    }
  }

  if (enabledRequiredContactType.value && !currentChat.value.contact_kind) {
    useAlert(t('CONVERSATION.CONTACT_TYPE_REQUIRED'));
    showContactSidebar();
    return;
  }

  isLoading.value = true;
  store
    .dispatch('toggleStatus', {
      conversationId: currentChat.value.id,
      status,
      snoozedUntil,
    })
    .then(() => {
      useAlert(t('CONVERSATION.CHANGE_STATUS'));
      isLoading.value = false;
    });
};

const onCmdOpenConversation = () => {
  toggleStatus(wootConstants.STATUS_TYPE.OPEN);
};

const onCmdResolveConversation = () => {
  toggleStatus(wootConstants.STATUS_TYPE.RESOLVED);
};

const showContactSidebar = () => {
  return updateUISettings({
    is_contact_sidebar_open: true,
    is_conv_actions_open: true,
  });
}

const closeConversation = () => {
  closeDropdown();
  store.dispatch('closeConversation', {
    conversationId: currentChat.value.id,
    closed: true
  }).then(() => {
    useAlert('Conversation is closed');
    currentChat.value.closed = true
  });
}

const uncloseConversation = () => {
  closeDropdown();
  store.dispatch('closeConversation', {
    conversationId: currentChat.value.id,
    closed: false
  }).then(() => {
    useAlert('Conversation is unclosed');
    currentChat.value.closed = false
  });
}

const keyboardEvents = {
  'Alt+KeyM': {
    action: () => arrowDownButtonRef.value?.$el.click(),
    allowOnFocusedInput: true,
  },
  'Alt+KeyE': {
    action: async () => {
      await toggleStatus(wootConstants.STATUS_TYPE.RESOLVED);
    },
  },
  '$mod+Alt+KeyE': {
    action: async event => {
      const { all, activeIndex, lastIndex } = getConversationParams();
      await toggleStatus(wootConstants.STATUS_TYPE.RESOLVED);

      if (activeIndex < lastIndex) {
        all[activeIndex + 1].click();
      } else if (all.length > 1) {
        all[0].click();
        document.querySelector('.conversations-list').scrollTop = 0;
      }
      event.preventDefault();
    },
  },
};

useKeyboardEvents(keyboardEvents);

useEmitter(CMD_REOPEN_CONVERSATION, onCmdOpenConversation);
useEmitter(CMD_RESOLVE_CONVERSATION, onCmdResolveConversation);
</script>

<template>
  <div class="relative flex items-center justify-end resolve-actions">
    <div class="button-group">
      <woot-button
        v-if="isOpen"
        class-names="resolve"
        color-scheme="success"
        icon="checkmark"
        emoji="✅"
        :is-loading="isLoading"
        @click="onCmdResolveConversation"
      >
        {{ $t('CONVERSATION.HEADER.RESOLVE_ACTION') }}
      </woot-button>
      <woot-button
        v-else-if="isResolved"
        class-names="resolve"
        color-scheme="warning"
        icon="arrow-redo"
        emoji="👀"
        :is-loading="isLoading"
        @click="onCmdOpenConversation"
      >
        {{ t('CONVERSATION.HEADER.REOPEN_ACTION') }}
      </woot-button>
      <woot-button
        v-else-if="showOpenButton"
        class-names="resolve"
        color-scheme="primary"
        icon="person"
        :is-loading="isLoading"
        @click="onCmdOpenConversation"
      >
        {{ t('CONVERSATION.HEADER.OPEN_ACTION') }}
      </woot-button>
      <woot-button
        v-if="showAdditionalActions"
        ref="arrowDownButtonRef"
        :color-scheme="buttonClass"
        :disabled="isLoading"
        icon="chevron-down"
        emoji="🔽"
        @click="openDropdown"
      />
    </div>
    <div
      v-if="showActionsDropdown"
      v-on-clickaway="closeDropdown"
      class="dropdown-pane dropdown-pane--open left-auto top-[2.625rem] mt-0.5 right-0 max-w-[12.5rem] min-w-[9.75rem]"
    >
      <WootDropdownMenu class="mb-0">
        <WootDropdownItem v-if="!isPending">
          <woot-button
            variant="clear"
            color-scheme="secondary"
            size="small"
            icon="snooze"
            @click="() => openSnoozeModal()"
          >
            {{ t('CONVERSATION.RESOLVE_DROPDOWN.SNOOZE_UNTIL') }}
          </woot-button>
        </WootDropdownItem>
        <WootDropdownItem v-if="!isPending">
          <woot-button
            variant="clear"
            color-scheme="secondary"
            size="small"
            icon="book-clock"
            @click="() => toggleStatus(wootConstants.STATUS_TYPE.PENDING)"
          >
            {{ t('CONVERSATION.RESOLVE_DROPDOWN.MARK_PENDING') }}
          </woot-button>
        </WootDropdownItem>
        <WootDropdownItem v-if="canCloseConversation">
          <woot-button
            variant="clear"
            color-scheme="secondary"
            size="small"
            icon="lock-closed"
            @click="() => closeConversation()"
          >
            {{ $t('CONVERSATION.RESOLVE_DROPDOWN.CLOSE') }}
          </woot-button>
        </WootDropdownItem>
        <WootDropdownItem v-if="canUncloseConversation">
          <woot-button
            variant="clear"
            color-scheme="secondary"
            size="small"
            icon="lock-shield"
            @click="() => uncloseConversation()"
          >
            {{ $t('CONVERSATION.RESOLVE_DROPDOWN.UNCLOSE') }}
          </woot-button>
        </WootDropdownItem>
      </WootDropdownMenu>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.dropdown-pane {
  .dropdown-menu__item {
    @apply mb-0;
  }
}
</style>
