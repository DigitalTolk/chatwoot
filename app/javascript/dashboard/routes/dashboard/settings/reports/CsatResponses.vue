<script>
import { mapGetters } from 'vuex';
import { useAlert, useTrack } from 'dashboard/composables';
import CsatMetrics from './components/CsatMetrics.vue';
import CsatTable from './components/CsatTable.vue';
import ReportFilterSelector from './components/FilterSelector.vue';
import { generateFileName } from '../../../../helper/downloadHelper';
import { REPORTS_EVENTS } from '../../../../helper/AnalyticsHelper/events';
import { FEATURE_FLAGS } from '../../../../featureFlags';
import CsatQuestionGroup from './components/CsatQuestionGroup.vue';

export default {
  name: 'CsatResponses',
  components: {
    CsatMetrics,
    CsatTable,
    ReportFilterSelector,
    CsatQuestionGroup,
  },
  data() {
    return {
      pageIndex: 0,
      from: 0,
      to: 0,
      userIds: [],
      inbox: [],
      team: [],
      rating: [],
      label: [],
      question: [],
      groudByQuestions: false,
    };
  },
  computed: {
    ...mapGetters({
      accountId: 'getCurrentAccountId',
      isFeatureEnabledOnAccount: 'accounts/isFeatureEnabledonAccount',
    }),
    requestPayload() {
      return {
        from: this.from,
        to: this.to,
        user_ids: this.userIds,
        inbox_id: this.inbox,
        team_id: this.team,
        rating: this.rating,
        label: this.label,
        question: this.question,
      };
    },
    isTeamsEnabled() {
      return this.isFeatureEnabledOnAccount(
        this.accountId,
        FEATURE_FLAGS.TEAM_MANAGEMENT
      );
    },
  },
  methods: {
    getAllData() {
      try {
        this.$store.dispatch('csat/getMetrics', this.requestPayload);
        this.$store.dispatch('csat/getQuestions', this.requestPayload);
        this.getResponses();
      } catch {
        useAlert(this.$t('REPORT.DATA_FETCHING_FAILED'));
      }
    },
    getResponses() {
      this.$store.dispatch('csat/get', {
        page: this.pageIndex + 1,
        ...this.requestPayload,
      });
    },
    downloadReports() {
      const type = 'csat';
      try {
        this.$store.dispatch('csat/downloadCSATReports', {
          fileName: generateFileName({ type, to: this.to }),
          ...this.requestPayload,
        });
      } catch (error) {
        useAlert(this.$t('REPORT.CSAT_REPORTS.DOWNLOAD_FAILED'));
      }
    },
    onPageNumberChange(pageIndex) {
      this.pageIndex = pageIndex;
      this.getResponses();
    },
    onFilterChange({
      from,
      to,
      selectedAgents,
      selectedInbox,
      selectedTeam,
      selectedRating,
      selectedLabel,
      selectedQuestion,
    }) {
      // do not track filter change on inital load
      if (this.from !== 0 && this.to !== 0) {
        useTrack(REPORTS_EVENTS.FILTER_REPORT, {
          filterType: 'date',
          reportType: 'csat',
        });
      }

      this.from = from;
      this.to = to;
      this.userIds = selectedAgents && selectedAgents.map(el => el.id);
      this.inbox = selectedInbox &&selectedInbox.map(el => el.id);
      this.team = selectedTeam && selectedTeam.map(el => el.id);
      this.rating = selectedRating && selectedRating.map(el => el.value);
      this.label =  selectedLabel && selectedLabel.map(el => el.title);
      this.question = selectedQuestion && selectedQuestion.map(el => el.id);
      this.getAllData();
    },
  },
};
</script>

<template>
  <div class="flex-1 p-4 overflow-auto">
    <ReportFilterSelector
      show-agents-filter
      show-inbox-filter
      show-rating-filter
      show-labels-filter
      show-question-filter
      :show-team-filter="isTeamsEnabled"
      :show-business-hours-switch="false"
      @filter-change="onFilterChange"
      multiple-labels
      multiple-teams
      multiple-inboxes
      multiple-ratings
      multiple-questions
    />
    <woot-button
      color-scheme="success"
      class-names="button--fixed-top"
      icon="arrow-download"
      @click="downloadReports"
    >
      {{ $t('CSAT_REPORTS.DOWNLOAD') }}
    </woot-button>
    <CsatMetrics :filters="requestPayload" />
    <div>
      <input v-model="groudByQuestions" type="checkbox" :value="true" />
      <label>Group by questions</label>
    </div>
    <CsatQuestionGroup v-if="groudByQuestions" />
    <CsatTable v-else :page-index="pageIndex" @page-change="onPageNumberChange" />
  </div>
</template>
