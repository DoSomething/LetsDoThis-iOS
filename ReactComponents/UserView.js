'use strict';

import React, {
  Component,
  ListView,
  StyleSheet,
  Text,
  Image,
  RefreshControl,
  TouchableHighlight,
  ActivityIndicatorIOS,
  View
} from 'react-native';

var Style = require('./Style.js');
var UserViewController = require('react-native').NativeModules.LDTUserViewController;
var ReportbackItemView = require('./ReportbackItemView.js');

var UserView = React.createClass({
  getInitialState: function() {
    var getSectionData = (dataBlob, sectionID) => {
      return dataBlob[sectionID];
    }
    var getRowData = (dataBlob, sectionID, rowID) => {
      return dataBlob[sectionID + ':' + rowID];
    }
    return {
      dataSource : new ListView.DataSource({
        getSectionData          : getSectionData,
        getRowData              : getRowData,
        rowHasChanged           : (row1, row2) => row1 !== row2,
        sectionHeaderHasChanged : (s1, s2) => s1 !== s2
      }),
      isRefreshing: false,
      loaded: false,
      error: null,
    };
  },
  componentDidMount: function() {
    this.fetchData();
  },
  componentWillUpdate: function() {
    this.fetchData();
  },
  fetchData: function() {
    var options = { 
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Session': this.props.sessionToken,
        'X-DS-REST-API-Key': this.props.apiKey,
      },
    };
    fetch(this.props.url, options)
      .then((response) => response.json())
      .then((responseData) => {
        var signups = responseData.data,
          dataBlob = {},
          sectionIDs = [],
          rowIDs = [],
          i;

        if (!responseData.data) {
          // @todo Throw error
          return;
        }

        sectionIDs.push(0);
        dataBlob[0] = "Actions I'm doing";
        rowIDs[0] = [];
        sectionIDs.push(1);
        dataBlob[1] = "Actions I've done";
        rowIDs[1] = [];
        for (i = 0; i < signups.length; i++) {
          var signup = signups[i];
          // Filter out inactive campaigns.
          var campaign = UserViewController.campaigns[signup.campaign.id];
          if (!campaign) {
            continue;
          }
          signup.campaign = campaign;
          var sectionNumber = 0;
          if (signup.reportback) {
            sectionNumber = 1;
            signup.reportback = signup.reportback_data;
            signup.reportbackItem = signup.reportback.reportback_items.data[0];
            signup.user = signup.reportback.user;
          }
          rowIDs[sectionNumber].push(signup.id);
          dataBlob[sectionNumber + ':' + signup.id] = signup;
        }

        this.setState({
          dataSource : this.state.dataSource.cloneWithRowsAndSections(dataBlob, sectionIDs, rowIDs),
          loaded: true,
          error: null,
        });
      })
      .catch((error) => this.catchError(error))
      .done();
  },
  _onRefresh: function () {
    this.setState({isRefreshing: true});
    setTimeout(() => {
      this.fetchData();
      this.setState({
        isRefreshing: false,
      });
    }, 1000);
  },
  catchError: function(error) {
    console.log(error);
    this.setState({
      error: error,
    });
  },
  renderLoadingView: function() {
    // @todo DRY LoadingView ReactComponent
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicatorIOS animating={this.state.animating} style={[{height: 80}]} size="small" />
        <Text style={Style.textBody}>
          Loading profile...
        </Text>
      </View>
    );
  },
  renderError: function() {
    return (
      <View style={styles.loadingContainer}>
        <Text style={Style.textBody}>
          Epic Fail
        </Text>
      </View>
    );
  },
  render: function() {
    if (this.state.error) {
      return this.renderError();
    }
    if (!this.state.loaded) {
      return this.renderLoadingView();
    }
    return (
      <ListView
        style={Style.backgroundColorCtaBlue}
        dataSource={this.state.dataSource}
        renderRow={this.renderRow}
        renderHeader={this.renderHeader}
        renderSectionHeader = {this.renderSectionHeader}
        refreshControl={
          <RefreshControl
            refreshing={this.state.isRefreshing}
            onRefresh={this._onRefresh}
            tintColor="white"
            colors={['#ff0000', '#00ff00', '#0000ff']}
            progressBackgroundColor="#ffff00"
          />
        }
      />
    );
  },
  renderHeader: function() {
    var avatarURL = this.props.user.avatarURL;
    if (avatarURL.length == 0) {
      this.props.user.avatarURL = 'https://placekitten.com/g/600/600';
    }
    return (
      <View style={[Style.backgroundColorCtaBlue, styles.headerContainer]}>
        <Image
          style={styles.avatar}
          source={{uri: this.props.user.avatarURL}}
        />
        <Text style={[Style.textHeading, styles.headerText]}>
          {this.props.user.countryName.toUpperCase()}
        </Text>
      </View>
    );
  },
  renderSectionHeader(sectionData, sectionID) {
    return (
      <View style={styles.sectionContainer}>
        <Text style={[Style.textHeading, {textAlign: 'center'}]}>
          {sectionData.toUpperCase()}
        </Text>
      </View>
    );
  },
  renderRow: function(rowData) {
    if (rowData.reportback) {
      return this.renderDoneRow(rowData);
    }
    else {
      return this.renderDoingRow(rowData);
    }
  },
  renderDoingRow: function(signup) {
    if (this.props.isSelfProfile) {
      // Render Prove It button
    }
    return (
      <TouchableHighlight onPress={() => this._onPressDoingRow(signup)}>
        <View style={styles.row}>
          <Text style={[Style.textHeading, Style.textColorCtaBlue]}>
            {signup.campaign.title}
          </Text>
          <Text style={Style.textBody}>
            {signup.campaign.tagline}
          </Text>
        </View>
      </TouchableHighlight>
    );
  },
  renderDoneRow: function(rowData) {
    return (
      <TouchableHighlight onPress={() => this._onPressRow(rowData)}>
        <View>
          <ReportbackItemView
            key={rowData.reportbackItem.id}
            reportbackItem={rowData.reportbackItem}
            reportback={rowData.reportback} 
            campaign={rowData.campaign}
            user={rowData.user}
          />
        </View>
      </TouchableHighlight>
    );
  },
  _onPressRow(rowData) {
    UserViewController.presentCampaign(Number(rowData.campaign.id));
  },
  _onPressDoingRow(rowData) {
    UserViewController.presentCampaign(Number(rowData.campaign.id));
  },
});

var styles = React.StyleSheet.create({
  loadingContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#EEE',
  },
  headerContainer: {
    alignItems: 'center',
    flex: 1,
    padding: 20,
  },
  sectionContainer: {
    backgroundColor: '#F8F8F6',
    padding: 14,
  },
  avatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
    borderColor: 'white',
    borderWidth: 2,
    alignItems: 'center',
  },
  headerText: {
    color: 'white',
    flex: 1,
    textAlign: 'center',
  },
  row: {
    backgroundColor: 'white',
    padding: 8,
  },
});

module.exports = UserView;