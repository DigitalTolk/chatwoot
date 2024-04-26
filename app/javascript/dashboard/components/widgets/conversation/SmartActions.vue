<template>
  <div>
    <div 
      v-if="showSmartAction"
      v-on-clickaway="hideSmartAction"
      class="smart-actions-panel left-3 rtl:left-auto rtl:right-3 bottom-16 w-64 absolute z-30 rounded-md shadow-xl bg-white dark:bg-slate-800 py-5 px-5 border border-slate-25 dark:border-slate-700"
      :class="{ 'block visible': showSmartAction }"
      >
      <woot-button
        size="tiny"
        variant="clear"
        color-scheme="secondary"
        icon="dismiss"
        @click="hideSmartAction"
        class="float-right"
      />
      <h1 class="text-xl break-words overflow-hidden whitespace-nowrap font-medium text-ellipsis text-black-900 dark:text-slate-100 mb-0">
        2 smart actions detected from conversation
      </h1>
      <p class="text-slate-400 dark:text-slate-300">Proceed with each action and let AI do the rest e.g auto fill form</p>

      <div>
        <div v-for="action in actions" v-bind:key="action.index" class="smart-action-item bg-slate-25 dark:bg-slate-900 m-0 h-full min-h-0">
          <h3 class="text-black-900 dark:text-slate-400">{{ action.name }}</h3>
          <p class="text-slate-400 dark:text-slate-300">{{ action.desc }}</p>
          <p class="text-slate-600 dark:text-slate-300 action-from-to">{{ action.from }} → {{ action.to }}</p>
          <div>
            <woot-button
                size="tiny"
                class="smart-action-button"
                @click="toggleBookingPanel"
              >
              {{ action.action }}
              <fluent-icon 
                size="16"
                class="-mt-0.5 align-middle text-slate-600 dark:text-slate-300 inline-block"
                icon="arrow-up-right"
                >
              </fluent-icon>
            </woot-button>
          </div>
        </div>
      </div>
      <div>
      <div>
        <woot-button
          size="small"
          variant="clear"
          color-scheme="secondary"
          icon="settings"
          @click="openSetting"
          class="float-right"
        />
        <div class="flex smart-help-chevron text-slate-400 dark:text-slate-300 text-xs py-2" @click="toggleHelp">
          <fluent-icon v-if="openHelp" size="10" icon="chevron-down" class="mt-1 mr-2"/>
          <fluent-icon v-else size="10" icon="chevron-right" type="solid" class="mt-1 mr-2"/>
            Learn what is mart action and how it works
          </div>
        </div>
        <p class="text-sm text-slate-800 dark:text-slate-300" v-if="openHelp">
          Smart action is an AI-powered feature designed to assist support agents in real-time conversation
          analysis. With this new tool, agents can seamlessly detect key actions and cues during ongoing conversations,
          empowering them to provide faster, more accurate assistance to customers.
        </p>
      </div>

    </div>
    <div v-if="showBookingPanel"
      v-on-clickaway="hideBookingPanel"
      class="booking-panel left-3 rtl:left-auto rtl:right-3 bottom-16 w-64 absolute z-30 rounded-md shadow-xl bg-white dark:bg-slate-800 py-2 px-2 border border-slate-25 dark:border-slate-700"
      :class="{ 'block visible': showBookingPanel }"
      >
      <iframe id="booking-iframe" src=""></iframe>
    </div>
  </div>
</template>
<script>
import WootButton from '../../ui/WootButton.vue'
import { mixin as clickaway } from 'vue-clickaway';

export default {
  components: { WootButton },
  props: {
    showSmartAction: {
      type: Boolean,
      default: false,
    },
    hideSmartAction: {
      type: Function,
      default: () => {},
    }
  },
  mixins: [clickaway],
  data() {
    return {
      actions: [
        {
          index: 1,
          name: 'Create Booking',
          desc: 'User want to book translator with few requirements',
          action: 'Create Booking',
          from: 'booking form',
          to: 'all options',
          status: 'pending'
        },
        {
          index: 2,
          name: 'Create Booking',
          desc: 'User want to update the video meeting link of booking #77722',
          action: 'Create Booking',
          from: 'edit booking form',
          to: 'Video meeting option',
          status: 'Resolved'
        }
      ],
      showBookingPanel: false,
      openHelp: false,
    }
  },
  methods: {
    toggleBookingPanel() {
      this.showBookingPanel = !this.showBookingPane;

      setTimeout(function(){
        const iframe = document.getElementById('booking-iframe');
        iframe.src = "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d8002838.949212151!2d117.32494097817411!3d11.649251523926925!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x324053215f87de63%3A0x784790ef7a29da57!2sPhilippines!5e0!3m2!1sen!2sph!4v1714138547965!5m2!1sen!2sph";
      }, 500)
    },
    hideBookingPanel(){
      this.showBookingPanel = false;
    },
    toggleHelp(){
      this.openHelp = !this.openHelp;
    },
    openSetting(){
      console.log('open settings')
    }
  }
}

</script>
<style scoped lang="scss">
  .smart-actions-panel{
    position: fixed;
    bottom: 0;
    z-index: 99;
    left: 20px;
    width: 600px;
    color: white;
    height: 500px;
    border-radius: 5px;
  }
  .smart-action-item{
    // background: #F8F9FB;
    padding: 10px;
    border-radius: 5px;
    margin-bottom: 10px;
    // border: 1px solid #F1F2F4;

  }
  .action-from-to{
    font-size: var(--font-size-mini);
  }
  .smart-action-button{
    background: #343132;  
  }
  .smart-action-button:hover{
    background: #3a393a;
  }
  .smart-help-chevron{
    cursor: pointer;
  }
  .booking-panel{
    position: fixed;
    bottom: 0;
    left: 0;
    z-index: 100;
    width: 40vw;
    height: 100vh;
  }
  #booking-iframe{
    width: 100%;
    height: 100vh;
  }
</style>